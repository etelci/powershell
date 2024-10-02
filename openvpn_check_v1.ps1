# Yönetici olarak çalıştırılıp çalıştırılmadığını kontrol et
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "Bu script'i yönetici olarak çalıştırmalısınız. Lütfen PowerShell'i 'Yönetici olarak çalıştır'(Run as Administrator) seçeneğiyle yeniden başlatın."
    exit
}

# OpenVPN Hizmetlerini kontrol et ve gerekirse başlat
$services = @("OpenVPNService", "OpenVPNServiceInteractive")

foreach ($serviceName in $services) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service -eq $null) {
        Write-Host "$serviceName hizmeti yüklü değil."
    } else {
        if ($service.Status -eq "Running") {
            Write-Host "$serviceName hizmeti çalışıyor."
        } else {
            Write-Host "$serviceName hizmeti çalışmıyor. Hizmeti başlatmayı deniyorum..."
            try {
                Start-Service -Name $serviceName -ErrorAction Stop
                Write-Host "$serviceName hizmeti başarıyla başlatıldı."
            } catch {
                Write-Host "$serviceName hizmeti başlatılamadı: $($_.Exception.Message)"
            }
        }
    }
}

# OpenVPN GUI'nin çalışıp çalışmadığını kontrol et
$process = Get-Process -Name "openvpn-gui" -ErrorAction SilentlyContinue

if ($process -eq $null) {
    Write-Host "OpenVPN GUI çalışmıyor."
    Write-Host "OpenVPN GUI'yi başlatmayı deneyin."
} else {
    Write-Host "OpenVPN GUI çalışıyor."
}

# Olası hata mesajlarını kontrol etmek için Windows Olay Günlüğü'nü incele
$events = Get-WinEvent -LogName Application -FilterXPath "*[System[Provider[@Name='OpenVPN']]]" -ErrorAction SilentlyContinue

if ($events) {
    Write-Host "OpenVPN ile ilgili hata mesajları bulundu:"
    foreach ($event in $events) {
        Write-Host "[$($event.TimeCreated)] $($event.Message)"
    }
} else {
    Write-Host "OpenVPN ile ilgili herhangi bir hata mesajı bulunamadı."
}
