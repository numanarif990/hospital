# Minimal static file server for the Flutter web build (Windows PowerShell).
# No Flutter, Node, or Python required on the client's machine.

param(
    [int]$Port = 8080
)

$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm'  = 'text/html; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.mjs'  = 'application/javascript; charset=utf-8'
    '.json' = 'application/json; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.wasm' = 'application/wasm'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.gif'  = 'image/gif'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
    '.woff' = 'font/woff'
    '.woff2'= 'font/woff2'
    '.ttf'  = 'font/ttf'
    '.otf'  = 'font/otf'
    '.map'  = 'application/json'
}

function Get-LocalPath([string]$urlPath) {
    $decoded = [System.Uri]::UnescapeDataString($urlPath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($decoded)) {
        return Join-Path $root 'index.html'
    }

    $candidate = Join-Path $root $decoded
    if (Test-Path $candidate -PathType Leaf) {
        return $candidate
    }

    return Join-Path $root 'index.html'
}

Write-Host ''
Write-Host '  Hospital Web App is running'
Write-Host "  Open: http://localhost:$Port"
Write-Host ''
Write-Host '  Keep this window open while using the app.'
Write-Host '  Close this window to stop the app.'
Write-Host ''

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        try {
            $localPath = Get-LocalPath $request.Url.LocalPath
            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            $extension = [System.IO.Path]::GetExtension($localPath).ToLowerInvariant()

            if ($mimeTypes.ContainsKey($extension)) {
                $response.ContentType = $mimeTypes[$extension]
            } else {
                $response.ContentType = 'application/octet-stream'
            }

            $response.StatusCode = 200
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } catch {
            $response.StatusCode = 404
            $message = [System.Text.Encoding]::UTF8.GetBytes('Not found')
            $response.ContentLength64 = $message.Length
            $response.OutputStream.Write($message, 0, $message.Length)
        } finally {
            $response.OutputStream.Close()
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
