{ config, pkgs, lib, ... }:
let
  git = config.programs.git;
  gitSigning = git.signing;
  # HM: format is "ssh" | "openpgp" | …; jj backends are gpg | gpgsm | ssh | none.
  jjSigningBackend =
    if gitSigning.format == "ssh" then
      "ssh"
    else if gitSigning.format == "openpgp" then
      "gpg"
    else
      "none";
  # Derive jj signing from programs.git.signing (key + signer once).
  jjSigning =
    if gitSigning.key == null || gitSigning.format == null then
      null
    else
      {
        backend = jjSigningBackend;
        behavior = "own";
        key = gitSigning.key;
      }
      // lib.optionalAttrs (gitSigning.format == "ssh" && gitSigning.signer != null) {
        backends.ssh.program = gitSigning.signer;
      }
      // lib.optionalAttrs (gitSigning.format == "openpgp" && gitSigning.signer != null) {
        backends.gpg.program = gitSigning.signer;
      };
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = git.settings.user.name;
        email = git.settings.user.email;
      };

      # Single source of truth: programs.git.signing (see git/default.nix).
      # behavior=own: sign commits we author. git.sign-on-push follows signByDefault.
      signing = lib.mkIf (jjSigning != null) jjSigning;
      git.sign-on-push = gitSigning.signByDefault == true;

      ui = {
        default-command = "status";
        graph.style = "curved";
        pager = "${lib.getExe pkgs.delta}";
        diff-editor = ":builtin";
        diff-formatter = ":git";  # delta needs this
        # Keep in sync with programs.git merge.tool (jj has built-in recipes for common tools).
        merge-editor = git.settings.merge.tool;
        show-cryptographic-signatures = gitSigning.signByDefault == true;
      };

      template-aliases = {
        # .ago() is verbose English only; compress (3m, 2h, …).
        "compact_ago(ts)" = ''
          ts.ago()
            .replace(" minutes ago", "m")
            .replace(" minute ago", "m")
            .replace(" hours ago", "h")
            .replace(" hour ago", "h")
            .replace(" days ago", "d")
            .replace(" day ago", "d")
            .replace(" weeks ago", "w")
            .replace(" week ago", "w")
            .replace(" months ago", "mo")
            .replace(" month ago", "mo")
            .replace(" years ago", "y")
            .replace(" year ago", "y")
            .replace(" seconds ago", "s")
            .replace(" second ago", "s")
        '';
        # after("yesterday") ≈ start of local today; before("tomorrow") ≈ end of today.
        "is_same_day(ts)" = ''
          ts.after("yesterday") && ts.before("tomorrow")
        '';
        # Same-day: compact relative age, right-padded to 4 (e.g. "  3m", " 42m").
        # Older: fixed-width local datetime.
        "format_commit_time(ts)" = ''
          if(
            is_same_day(ts),
            pad_start(4, compact_ago(ts)),
            ts.local().format("%Y-%m-%d %H:%M"),
          )
        '';
      };

      templates = {
        # Line 1: ids, flags, time (relative if today else absolute), empty
        # ghost icon, bookmarks. Line 2: description.
        log = ''
          concat(
            separate(" ",
              change_id.shortest(8),
              commit_id.shortest(8),
              if(conflict, label("conflict", "(conflict)")),
              if(divergent, label("divergent", "(divergent)")),
              format_commit_time(committer.timestamp()),
              if(empty, label("empty", "󰊠")),
              bookmarks,
            ),
            "\n",
            "  ",
            if(description,
              description.first_line(),
              label("description placeholder", "(no description set)"),
            ),
            "\n",
          )
        '';

        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" = "heads(::to & ~description(exact:\"\") & (~empty() | merges()))";
      };

      aliases = {
        tug = ["bookmark" "move" "--from" "closest_bookmark(@)" "--to" "closest_pushable(@)"];
      };
    };
  };

  home.packages = with pkgs; [
    # jj-fzf
    jjui
    lazyjj
  ];
}
