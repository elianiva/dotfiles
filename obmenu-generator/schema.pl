#!/usr/bin/perl

# obmenu-generator - schema file

=for comment

    item:      add an item inside the menu               {item => ["command", "label", "icon"]},
    cat:       add a category inside the menu            {cat => ["name", "label", "icon"]},
    sep:       horizontal line separator                 {sep => undef}, {sep => "label"},
    pipe:      a pipe menu entry                         {pipe => ["command", "label", "icon"]},
    file:      include the content of an XML file        {file => "/path/to/file.xml"},
    raw:       any XML data supported by Openbox         {raw => q(...)},
    beg:       begin of a category                       {beg => ["name", "icon"]},
    end:       end of a category                         {end => undef},
    obgenmenu: generic menu settings                     {obgenmenu => ["label", "icon"]},
    exit:      default "Exit" action                     {exit => ["label", "icon"]},

=cut

# NOTE:
#    * Keys and values are case sensitive. Keep all keys lowercase.
#    * ICON can be a either a direct path to an icon or a valid icon name
#    * Category names are case insensitive. (X-XFCE and x_xfce are equivalent)

require "$ENV{HOME}/.config/obmenu-generator/config.pl";

## Text editor
my $editor = $CONFIG->{editor};

our $SCHEMA = [
    {sep => 'MENU'},

    #          COMMAND                 LABEL              ICON
    {item => ['xdg-open .',       'File Manager',   'system-file-manager']},
    {item => ['st',               'Terminal',       'utilities-terminal']},
    {item => ['xdg-open http://', 'Web Browser',    'web-browser']},

    {beg => ['Applications',  'start-here']},
      #          NAME            LABEL                ICON
      {cat => ['utility',     'Accessories', 'applications-utilities']},
      {cat => ['development', 'Development', 'applications-development']},
      {cat => ['education',   'Education',   'applications-science']},
      {cat => ['game',        'Games',       'applications-games']},
      {cat => ['graphics',    'Graphics',    'applications-graphics']},
      {cat => ['audiovideo',  'Multimedia',  'applications-multimedia']},
      {cat => ['network',     'Network',     'applications-internet']},
      {cat => ['office',      'Office',      'applications-office']},
      {cat => ['other',       'Other',       'applications-other']},
      {cat => ['settings',    'Settings',    'applications-accessories']},
      {cat => ['system',      'System',      'applications-system']},
    {end => undef},
    {pipe => ['calendar',         'Show Calendar',  'calendar']},

    {beg => ['Music Control',  'audio-x-generic']},
      {item => ['mpc toggle', 'Play/Pause', 'media-playback-start']},
      {item => ['mpc prev', 'Prev', 'media-seek-backward']},
      {item => ['mpc next', 'Next', 'media-seek-forward']},
    {end => undef},

    #             LABEL          ICON
    #{beg => ['My category',  'cat-icon']},
    #          ... some items ...
    #{end => undef},

    #            COMMAND     LABEL        ICON
    #{pipe => ['obbrowser', 'Disk', 'drive-harddisk']},

    ## Generic advanced settings
    #{sep       => undef},
    #{obgenmenu => ['Openbox Settings', 'applications-engineering']},
    #{sep       => undef},

    ## Custom advanced settings
    {beg => ['Advanced Settings', 'applications-system']},

      # Configuration files
      {item => ["$editor ~/.conkyrc",              'Conky RC',    'text-x-generic']},
      {item => ["$editor ~/.config/tint2/tint2rc", 'Tint2 Panel', 'text-x-generic']},

      # obmenu-generator category
      {beg => ['Obmenu-Generator', 'accessories-text-editor']},
        {item => ["$editor ~/.config/obmenu-generator/schema.pl", 'Menu Schema', 'text-x-generic']},
        {item => ["$editor ~/.config/obmenu-generator/config.pl", 'Menu Config', 'text-x-generic']},

        {sep  => undef},
        {item => ['obmenu-generator -s -c',    'Generate a static menu',             'accessories-text-editor']},
        {item => ['obmenu-generator -s -i -c', 'Generate a static menu with icons',  'accessories-text-editor']},
        {sep  => undef},
        {item => ['obmenu-generator -p',       'Generate a dynamic menu',            'accessories-text-editor']},
        {item => ['obmenu-generator -p -i',    'Generate a dynamic menu with icons', 'accessories-text-editor']},
        {sep  => undef},

        {item => ['obmenu-generator -d', 'Refresh cache', 'view-refresh']},
      {end => undef},

      # Openbox category
      {beg => ['Openbox', 'openbox']},
        {item => ["$editor ~/.config/openbox/autostart", 'Openbox Autostart',   'text-x-generic']},
        {item => ["$editor ~/.config/openbox/rc.xml",    'Openbox RC',          'text-x-generic']},
        {item => ["$editor ~/.config/openbox/menu.xml",  'Openbox Menu',        'text-x-generic']},
        {item => ['openbox --reconfigure',               'Reconfigure Openbox', 'openbox']},
      {end => undef},
    {end => undef},

    ## System menu
    {beg => ['System', 'system']},
      ## This option uses the default Openbox's "Exit" action
      {item => ["shutdown now", "Shutdown", "system-shutdown"]},
      {item => ["reboot", "Reboot", "system-reboot"]},
      {item => ['betterlockscreen -l', 'Lock', 'system-lock-screen']},
      {exit => ['Exit', 'application-exit']},
    {end => undef},

    ## This uses the 'oblogout' menu
    # {item => ['oblogout', 'Exit', 'application-exit']},
]
