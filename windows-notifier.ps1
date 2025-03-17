# Custom notification with parameters for title and message
param(
    [Parameter(Mandatory=$false)]
    [string]$Title = "WSL Notification",
    
    [Parameter(Mandatory=$false)]
    [string]$Message = "Hello World",
    
    [Parameter(Mandatory=$false)]
    [int]$Duration = 1000
)

# Ensure proper Unicode handling
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Temporarily disable notification sounds
$soundRegPath = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.Default\.Current'
try {
    # Save original sound setting
    $originalSound = Get-ItemProperty -Path $soundRegPath -Name '(Default)' -ErrorAction SilentlyContinue
    
    # Set sound to empty (silent)
    Set-ItemProperty -Path $soundRegPath -Name '(Default)' -Value '' -Type String -Force
    
    # Get screen dimensions
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    
    # Create custom notification form
    $form = New-Object System.Windows.Forms.Form
    $form.TopMost = $true
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $form.Width = 300
    $form.Height = 80
    $form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    
    # Position in top-right corner
    $form.Location = New-Object System.Drawing.Point(($screen.Right - $form.Width - 20), 20)
    
    # Check if Consolas Nerd Font is installed
    $fontFamily = "Consolas NF"
    $fontInstalled = $false
    
    foreach ($font in [System.Drawing.FontFamily]::Families) {
        if ($font.Name -eq $fontFamily -or $font.Name -match "Consolas.*Nerd") {
            $fontInstalled = $true
            $fontFamily = $font.Name
            break
        }
    }
    
    # Fallback to alternatives if Consolas Nerd Font isn't installed
    if (-not $fontInstalled) {
        $fontCandidates = @("Consolas", "DejaVu Sans Mono", "Cascadia Code", "Segoe UI", "Arial Unicode MS")
        
        foreach ($candidate in $fontCandidates) {
            $found = $false
            foreach ($font in [System.Drawing.FontFamily]::Families) {
                if ($font.Name -eq $candidate) {
                    $fontFamily = $candidate
                    $found = $true
                    break
                }
            }
            if ($found) { break }
        }
    }
    
    # Create notification text
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $Title
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $titleLabel.Font = New-Object System.Drawing.Font($fontFamily, 12, [System.Drawing.FontStyle]::Bold)
    $titleLabel.Location = New-Object System.Drawing.Point(10, 10)
    $titleLabel.AutoSize = $true
    $form.Controls.Add($titleLabel)
    
    $msgLabel = New-Object System.Windows.Forms.Label
    $msgLabel.Text = $Message
    $msgLabel.ForeColor = [System.Drawing.Color]::White
    $msgLabel.Font = New-Object System.Drawing.Font($fontFamily, 10)
    $msgLabel.Location = New-Object System.Drawing.Point(10, 40)
    $msgLabel.AutoSize = $true
    $form.Controls.Add($msgLabel)
    
    # Show form without stealing focus
    $form.Show()
    $form.TopMost = $true
    
    # Auto-close after the specified duration
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = $Duration
    $timer.Add_Tick({
        $form.Close()
        $timer.Stop()
    })
    $timer.Start()
    
    # Keep the script running until form is closed
    [System.Windows.Forms.Application]::Run($form)
}
finally {
    # Restore original sound setting if it existed
    if ($originalSound) {
        Set-ItemProperty -Path $soundRegPath -Name '(Default)' -Value $originalSound.'(Default)' -Type String -Force
    }
}
