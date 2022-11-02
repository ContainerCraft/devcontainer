package sshd

import (
    "os"
    "log"
    "os/exec"
)

const (
	sshdExec string = "/usr/sbin/sshd"
	defaultSshdFlags string = "-e -f /etc/ssh/sshd_config -E /dev/stdout"
)

func StartSshd() {
	// Start SSHD service
	sshdFlags, found := os.LookupEnv("SSHD_FLAGS")
	if !found {
		sshdFlags = defaultSshdFlags
	}

    sshdCmd := sshdExec + sshdFlags

	err := exec.Command(sshdCmd)
	if err != nil {
		log.Fatal(err)
	}
}
