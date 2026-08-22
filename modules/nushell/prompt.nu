# A git prompt similar to that of starship, but only with the the integrations
# I actually need.
$env.PROMPT_COMMAND = {||
  let prev_exit_code = $env.LAST_EXIT_CODE
  
  let branch_out = git branch --show-current | complete
  let is_in_git = ($branch_out | get exit_code) == 0
  let prompt = if $is_in_git {
    # Find the current path relative to the git directory.
    let git_workdir = git rev-parse --show-toplevel
    let git_workdir_basename = $git_workdir | path basename
    let dir = if $git_workdir == $env.PWD {
      $git_workdir_basename
    } else {
      $git_workdir_basename | path join ($env.PWD | path relative-to $git_workdir)
    }
    
    let branch = $branch_out | get stdout | str trim

    $"(ansi cyan_bold)($dir)(ansi reset) on (ansi purple_bold) ($branch)(ansi reset)"
  } else if $env.PWD == $env.HOME {
    $"(ansi cyan_bold)~(ansi reset)"
  } else {
    $"(ansi cyan_bold)($env.PWD)(ansi reset)"
  }

  let prompt = if "IN_NIX_SHELL" in $env {
      $"($prompt) via (ansi blue_bold)❄️ ($env.name)(ansi reset)"
  } else {
    $prompt
  }

  let duration = $env.CMD_DURATION_MS | into duration --unit ms
  let prompt = if $duration < 1sec {
    $prompt
  } else {
    $"($prompt) took (ansi yellow_bold)($duration)(ansi reset)"
  }
  
  $"\n($prompt)\n"
}

$env.PROMPT_INDICATOR = {||
  if $env.LAST_EXIT_CODE == 0 {
    $"(ansi green_bold)❯(ansi reset) "
  } else {
    $"(ansi red_bold)($env.LAST_EXIT_CODE) ❯(ansi reset) "
  }
}

$env.PROMPT_COMMAND_RIGHT = ""
