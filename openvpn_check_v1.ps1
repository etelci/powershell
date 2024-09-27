# OpenVPN hizmetinin durumunu kontrol et
$service = Get-Service -Name "OpenVPNService" -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Host "OpenVPN hizmeti yüklü değil."
} else {
    if ($service.Status -eq "Running") {
        Write-Host "OpenVPN hizmeti çalışıyor."
    } else {
        Write-Host "OpenVPN hizmeti çalışmıyor. Hizmeti başlatmayı deniyorum..."
        try {
            Start-Service -Name "OpenVPNService"
            Write-Host "OpenVPN hizmeti başarıyla başlatıldı."
        } catch {
            Write-Host "OpenVPN hizmeti başlatılamadı: $($_.Exception.Message)"
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
