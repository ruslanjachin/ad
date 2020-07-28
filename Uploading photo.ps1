Import-Module ActiveDirectory
# 
# Первый параметр - путь к папке, второй - атрибут AD (thumbnailPhoto - для Outlook, jpegPhoto - для портала)
function Set-ADPhoto($path, $ADPhotoAttribute) 
{
    # Папка, в которую будут перемещаться загруженные фотографии
    $uploaded = $path + "\uploaded"

    # Проверка папки на существование
    if(Test-Path $path)
    {
        # Получение списка jpg файлов (полный путь до файла)
        $photos = Get-ChildItem -Path $path -File -Filter "*.jpg"

        # Проверка на наличие фотографий 
        if($photos.count -eq 0){return}
            
            # Начинаем перебирать фотки
            foreach ($photo in $photos)
            {               
                # Поиск активного пользователя в AD по имени файла, которое должно совпадать с Display Name (используется LDAP запрос)
                $user = Get-ADUser -LDAPFilter "(&(DisplayName=$($photo.BaseName))(!(useraccountcontrol:1.2.840.113556.1.4.803:=2)))"

                if(!$user){continue}

                # Загрузка фотографии в AD
                Set-ADUser $user.samAccountName -Replace @{$ADPhotoAttribute=([byte[]](Get-Content $photo.FullName -Encoding byte))}

                # Попытка создать папку uploaded, если ее не существует
                try
                {
                    if(!(Test-Path $uploaded))
                    {
                        New-Item -ItemType "directory" -Path $uploaded | Out-Null
                    }
                }
                catch{continue}

                try
                {
                    # Перенос загруженной фотографии в папку uploaded текущего каталога
                    Move-Item -Path $photo.FullName -Destination $uploaded
                }
                catch{continue}
            }   
    }
    else {return}
}


# Пути к папкам
$path_96  =  "C:\test\96"
$path_300 =  "C:\test\300"

# Запуск скрипта
Set-ADPhoto -path $path_96  -ADPhotoAttribute thumbnailPhoto
Set-ADPhoto -path $path_300 -ADPhotoAttribute jpegPhoto

