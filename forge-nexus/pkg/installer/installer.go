package installer

import "fmt"

// Installer defines the interface for an OS-specific installer.
// Each supported OS will have a struct that implements this interface.
type Installer interface {
	Install() error
}

// UbuntuInstaller handles installation on Ubuntu systems.
type UbuntuInstaller struct{}

// Install implements the Installer interface for Ubuntu.
func (i *UbuntuInstaller) Install() error {
	fmt.Println("Running Ubuntu installer...")
	fmt.Println("Updating package lists with 'apt-get update'...")
	// Placeholder for executing shell commands
	fmt.Println("Installing dependencies (e.g., ufw)...")
	// Placeholder for executing shell commands
	fmt.Println("Ubuntu installation tasks complete.")
	return nil
}

// CentOSInstaller handles installation on CentOS systems.
type CentOSInstaller struct{}

// Install implements the Installer interface for CentOS.
func (i *CentOSInstaller) Install() error {
	fmt.Println("Running CentOS installer...")
	fmt.Println("Updating package lists with 'yum check-update'...")
	// Placeholder for executing shell commands
	fmt.Println("Installing dependencies (e.g., firewalld)...")
	// Placeholder for executing shell commands
	fmt.Println("CentOS installation tasks complete.")
	return nil
}

// UnsupportedInstaller is used for operating systems that are not supported.
type UnsupportedInstaller struct {
	OS_ID string
}

// Install implements the Installer interface for unsupported OSes.
func (i *UnsupportedInstaller) Install() error {
	return fmt.Errorf("unsupported operating system: %s", i.OS_ID)
}
