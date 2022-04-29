clear

function CompileMesh ($n) {
  if (!(($n -eq 2) -or ($n -eq 3))) {
    Write-Output "Invalid parameter"
  }
  else {
    gmsh -$n ./mesh.geo -o build/sound_pressure.msh
  }
}

function Compile {
  if (Test-Path -PathType Container -Path build) {
    Push-Location build
    cmake -G"Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=True ..
    cmake --build .
    Pop-Location
  }
  else {
    New-Item -Path build -ItemType Directory
    Compile
  }
}

function Run() {
  Compile
  Push-Location build
  ./sound_pressure
  Pop-Location
}

if (!$args[0]) {
  Write-Output "Specify a command"
}
else {
  switch ($args[0]) {
    "build" { Compile }
    "run" { Run }
    "mesh" {
      if (!$args[1]) {
        Write-Output "Insert mesh dimension (2 or 3)D"
      }
      else {
        CompileMesh($args[1])
      }
    }
    "clear" {
      Remove-Item -Path build -Force
    }
    default { Write-Output "Command not supported" }
  }
}
