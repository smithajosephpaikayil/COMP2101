get-ciminstance win32_networkadapterconfiguration |
    Where-Object IPEnabled -eq "True" |
        Select-Object -Property @{n="Adapter Description";e={$_.description}},
				@{n="Index";e={$_.index}},
                                @{n="IP Address";e={$_.ipaddress}},
                                @{n="Subnet Mask";e={$_.ipsubnet}},
                                @{n="DNS Domain Name";e={$_.dnshostname}},
                                @{n="DNS Server"; e={$_.DNSServerSearchOrder}} |
Format-Table -autosize