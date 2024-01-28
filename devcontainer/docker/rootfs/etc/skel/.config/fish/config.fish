if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    direnv hook fish | source
end
function sshagent_findsockets
	find /tmp -uid (id -u) -type s -name agent.\* 2>/dev/null
end

function sshagent_testsocket
    if [ ! -x (command which ssh-add) ] ;
        echo "ssh-add is not available; agent testing aborted"
        return 1
    end

    if [ X"$argv[1]" != X ] ;
        set -xg SSH_AUTH_SOCK $argv[1]
    end

    if [ X"$SSH_AUTH_SOCK" = X ]
        return 2
    end

    if [ -S $SSH_AUTH_SOCK ] ;
        ssh-add -l > /dev/null
        if [ $status = 2 ] ;
            echo "Socket $SSH_AUTH_SOCK is dead!  Deleting!"
            rm -f $SSH_AUTH_SOCK
            return 4
        else ;
            echo "Found ssh-agent $SSH_AUTH_SOCK"
            return 0
        end
    else ;
        echo "$SSH_AUTH_SOCK is not a socket!"
        return 3
    end
end


function ssh_agent_init
    # ssh agent sockets can be attached to a ssh daemon process or an
    # ssh-agent process.

    set -l AGENTFOUND 0

    # Attempt to find and use the ssh-agent in the current environment
    if sshagent_testsocket ;
        set AGENTFOUND 1
    end

    # If there is no agent in the environment, search /tmp for
    # possible agents to reuse before starting a fresh ssh-agent
    # process.
    if [ $AGENTFOUND = 0 ];
        for agentsocket in (sshagent_findsockets)
            if [ $AGENTFOUND != 0 ] ;
                break
            end
            if sshagent_testsocket $agentsocket ;
            set AGENTFOUND 1
        end

        end
    end

    # If at this point we still haven't located an agent, it's time to
    # start a new one
    if [ $AGENTFOUND = 0 ] ;
	echo need to start a new agent
	eval (ssh-agent -c)
    end

    # Finally, show what keys are currently in the agent
    # ssh-add -l
end

# Load environment variables from a file
#function envsource
#  for line in (cat $argv | grep -v '^#')
#    set item (string split -m 1 '=' $line)
#    set -gx $item[1] $item[2]
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
touch ~/.env
envsource ~/.env 2>&1 1>/dev/null

ssh_agent_init 2>&1 1>/dev/null
set fish_greeting
set -gx  LC_ALL en_US.UTF-8
set -gx  LANG en_US.UTF-8
set PATH /home/k/.krew/bin $PATH
