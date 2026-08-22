$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5_000_000
$env.config.history.isolation = true

# Turn off welcome banner.
$env.config.show_banner = false;

$env.config.completions.algorithm = "fuzzy";
# CTRL + C always results in a message being printed which is annoying. 
$env.config.display_errors.termination_signal = false;

$env.config.footer_mode = "auto";
$env.config.table.index_mode = "auto";
$env.config.table.show_empty = false;

# year/month/date hour:minute:seconds
$env.config.datetime_format.normal = "%Y/%m/%d %I:%M:%S"

$env.config.float_precision = 4
