# Session-bus owner of org.kde.StatusNotifierWatcher.
#
# Noctalia claims that name when it is free, and only registers as a
# host when something else already owns it. Tray clients quit if the
# name becomes unowned, so this process holds it for the whole login.
# Request flags are empty: a taken name is queued, not stolen and not
# refused. systemd Type=dbus stays activating until we are primary.

import asyncio
import sys

from dbus_next import Message, MessageType
from dbus_next.aio import MessageBus
from dbus_next.constants import NameFlag, PropertyAccess, RequestNameReply
from dbus_next.service import ServiceInterface, dbus_property, method, signal

BUS_NAME = "org.kde.StatusNotifierWatcher"
OBJECT_PATH = "/StatusNotifierWatcher"
ITEM_PATH = "/StatusNotifierItem"
IFACE = "org.kde.StatusNotifierWatcher"

NAME_OWNER_MATCH = (
    "type='signal',sender='org.freedesktop.DBus',"
    "interface='org.freedesktop.DBus',path='/org/freedesktop/DBus',"
    "member='NameOwnerChanged'"
)


class Item:
    def __init__(self, bus, path):
        self.bus = bus
        self.path = path
        # KDE concatenates. Noctalia splits on the first slash.
        self.id = bus + path


class Watcher(ServiceInterface):
    def __init__(self):
        super().__init__(IFACE)
        self._items = []
        self._hosts = set()
        # Set by the bus handler immediately before the method runs.
        # dbus-next 0.2 does not pass the caller into @method.
        self._sender = ""

    def on_message(self, msg):
        if (
            msg.message_type == MessageType.METHOD_CALL
            and msg.interface == IFACE
            and msg.path == OBJECT_PATH
        ):
            self._sender = msg.sender or ""
            return None

        if (
            msg.message_type == MessageType.SIGNAL
            and msg.interface == "org.freedesktop.DBus"
            and msg.member == "NameOwnerChanged"
            and msg.body
            and len(msg.body) == 3
        ):
            name, _old, new = msg.body
            if new == "":
                self._drop_bus_name(name)
        return None

    def _parse_item(self, service):
        if service.startswith("/"):
            if not self._sender:
                return None
            return Item(self._sender, service)
        slash = service.find("/")
        if slash > 0:
            return Item(service[:slash], service[slash:])
        if not service:
            return None
        return Item(service, ITEM_PATH)

    def _item_ids(self):
        return [item.id for item in self._items]

    def _drop_bus_name(self, name):
        removed = [item for item in self._items if item.bus == name]
        if removed:
            self._items = [item for item in self._items if item.bus != name]
            for item in removed:
                self.StatusNotifierItemUnregistered(item.id)
            self.emit_properties_changed(
                {"RegisteredStatusNotifierItems": self._item_ids()}
            )

        if name in self._hosts:
            self._hosts.discard(name)
            # Items stay. Only the drawing host went away.
            if not self._hosts:
                self.StatusNotifierHostUnregistered()
            self.emit_properties_changed(
                {"IsStatusNotifierHostRegistered": bool(self._hosts)}
            )

    @method()
    def RegisterStatusNotifierItem(self, service: "s"):  # noqa: F821
        item = self._parse_item(service)
        duplicate = item is not None and any(
            existing.id == item.id for existing in self._items
        )
        if item is None or duplicate:
            return
        self._items.append(item)
        self.StatusNotifierItemRegistered(item.id)
        self.emit_properties_changed(
            {"RegisteredStatusNotifierItems": self._item_ids()}
        )

    @method()
    def RegisterStatusNotifierHost(self, service: "s"):  # noqa: F821
        if service.startswith("/"):
            name = self._sender
        else:
            name = service
        if not name or name in self._hosts:
            return
        self._hosts.add(name)
        self.StatusNotifierHostRegistered()
        self.emit_properties_changed(
            {"IsStatusNotifierHostRegistered": True}
        )

    @dbus_property(access=PropertyAccess.READ)
    def RegisteredStatusNotifierItems(self) -> "as":  # noqa: F722
        return self._item_ids()

    @dbus_property(access=PropertyAccess.READ)
    def IsStatusNotifierHostRegistered(self) -> "b":  # noqa: F821
        return bool(self._hosts)

    @dbus_property(access=PropertyAccess.READ)
    def ProtocolVersion(self) -> "i":  # noqa: F821
        return 0

    @signal()
    def StatusNotifierItemRegistered(self, service) -> "s":  # noqa: F821
        return service

    @signal()
    def StatusNotifierItemUnregistered(self, service) -> "s":  # noqa: F821
        return service

    @signal()
    def StatusNotifierHostRegistered(self):
        return None

    @signal()
    def StatusNotifierHostUnregistered(self):
        return None


async def main():
    bus = await MessageBus().connect()
    watcher = Watcher()
    # Export before the name request so the object exists the moment
    # we become primary, including after time spent in the queue.
    bus.export(OBJECT_PATH, watcher)
    bus.add_message_handler(watcher.on_message)
    await bus.call(
        Message(
            destination="org.freedesktop.DBus",
            interface="org.freedesktop.DBus",
            path="/org/freedesktop/DBus",
            member="AddMatch",
            signature="s",
            body=[NAME_OWNER_MATCH],
        )
    )

    reply = await bus.request_name(BUS_NAME, NameFlag.NONE)
    if reply not in (
        RequestNameReply.PRIMARY_OWNER,
        RequestNameReply.IN_QUEUE,
        RequestNameReply.ALREADY_OWNER,
    ):
        print(f"could not request {BUS_NAME}: {reply}", file=sys.stderr)
        raise SystemExit(1)

    await bus.wait_for_disconnect()


if __name__ == "__main__":
    asyncio.run(main())
