Get-ADUser -f {Enabled -eq "True"} -pr Name,Title,Department,Manager `
| select Name, Title, Department, `
@{N='Manager';E={(Get-ADUser $_.Manager).Name}}, `
@{N='Manager Title';E={(Get-ADUser $_.Manager -pr Title).Title}}, `
@{N='Manager Department';E={(Get-ADUser $_.Manager -pr Department).Department}} `
| export-csv "C:\Report.csv" -Delimiter ';' -NoTypeInformation -Encoding utf8