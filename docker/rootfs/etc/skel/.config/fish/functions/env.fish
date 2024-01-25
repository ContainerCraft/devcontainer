# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envsource.fish
#
# Usage: envsource <path/to/env>

#function envsource
#  for line in (cat $argv | grep -v '^#')
#    set item (string split -m 1 '=' $line)
#    set -gx $item[1] $item[2]
#    echo "Exported key $item[1]"
#  end
#end

function envsource
    # Set default file to ~/.env
    set file ~/.env

    # If an argument is provided, use it as the file
    if count $argv > /dev/null
        set file $argv[1]
    end

    # Load environment variables from the file
    for line in (cat $file | grep -v '^#')
        set item (string split -m 1 '=' $line)
        set -gx $item[1] $item[2]
        echo "Exported key $item[1]"
    end
end
