# Local Publish — Publicar webapps locales en Internet

Herramienta **independiente** para cualquier proyecto en `C:\` (ScrapIt, Vite, Django, etc.).

Crea un **túnel público** con [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) (`cloudflared`):
- Gratis
- Sin cuenta
- Genera una URL tipo `https://xxxx.trycloudflare.com`

---

## Inicio rápido

### Opción A — Doble clic
1. Asegúrate de que tu app local esté corriendo (`npm run dev`, etc.)
2. Doble clic en:
   ```
   C:\<ruta-a-directorio-clonado>\local-publish\publish-local.bat
   ```
3. Escribe la URL (ej. `http://localhost:3000` o solo `3000`)
4. Copia la URL pública que aparece y compártela

### Opción B — Terminal
```bat
cd C:\<ruta-a-directorio-clonado>\local-publish
publish.cmd http://localhost:3000
```

Solo el puerto:
```bat
publish.cmd 3000
```

Abrir el navegador automáticamente:
```bat
publish.cmd http://localhost:3000 --open
```

PowerShell directo:
```powershell
cd C:\<ruta-a-directorio-clonado>\local-publish
.\Publish-Local.ps1 http://localhost:3000 -OpenBrowser
```

---

## Ejemplos por proyecto (C:\Proy)

| Proyecto | Comando típico local | Publicar con |
|----------|----------------------|--------------|
| scrap-it | `npm run dev` → :3000 | `publish.cmd 3000` |
| Vite | `npm run dev` → :5173 | `publish.cmd 5173` |
| Django | `runserver` → :8000 | `publish.cmd 8000` |
| FastAPI | `uvicorn` → :8000 | `publish.cmd http://127.0.0.1:8000` |

---

## Cómo funciona

1. La primera vez descarga `cloudflared.exe` en `bin\`
2. Levanta un túnel desde tu URL local hacia Internet
3. Muestra (y copia al portapapeles) la URL pública
4. Mientras la ventana esté abierta, cualquiera puede ver tu app
5. `Ctrl+C` o cerrar la ventana → se corta el túnel

---

## Crear un acceso directo en el Escritorio

```powershell
$Wsh = New-Object -ComObject WScript.Shell
$Shortcut = $Wsh.CreateShortcut("$env:USERPROFILE\Desktop\Local Publish.lnk")
$Shortcut.TargetPath = "C:\<ruta-a-directorio-clonado>\local-publish\publish-local.bat"
$Shortcut.WorkingDirectory = "C:\<ruta-a-directorio-clonado>\local-publish"
$Shortcut.Description = "Publicar webapp local en Internet"
$Shortcut.Save()
```

---

## Requisitos

- Windows 10/11
- Conexión a Internet (para el túnel y la 1ª descarga)
- La webapp debe estar **corriendo en local** antes de publicar

---

## Seguridad

- Quien tenga el enlace puede ver lo que expone tu app (login, datos demo, etc.)
- No uses esto con datos sensibles reales
- La URL cambia cada vez que reinicias el túnel (modo quick tunnel)
- Cierra el túnel cuando termines

---

## Problemas frecuentes

**“No se pudo conectar a localhost”**  
Arranca primero la app (`npm run dev` en el proyecto).

**PowerShell bloquea el script**  
Ya se lanza con `-ExecutionPolicy Bypass` desde el `.bat`.

**Firewall / antivirus**  
Permite `cloudflared.exe` en `C:\<ruta-a-directorio-clonado>\local-publish\bin\`.

**Quiero un dominio fijo**  
Eso requiere cuenta Cloudflare y un túnel nombrado (no quick tunnel). Esta herramienta usa el modo rápido gratuito.
