# COMMANDS:
# build
# run
# mesh
# clear
# docker_create
# docker_rm

Clear-Host

function CompileMesh ($n)
{
  if (!(($n -eq 2) -or ($n -eq 3)))
  {
    Write-Output "Invalid parameter"
  } else
  {
    gmsh ./mesh.geo -$n -o build/sound_pressure.vtk
  }
}

function Compile
{
  if (Test-Path -PathType Container -Path build)
  {
    Push-Location build
    cmake -G"Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=True ..
    cmake --build .
    Copy-Item -Path compile_commands.json -Destination ..
    Pop-Location
  } else
  {
    New-Item -Path build -ItemType Directory
    Compile
  }
}

function Run()
{
  Compile
  Push-Location build
  ./sound_pressure
  Pop-Location
}

if (!$args[0])
{
  Write-Output "Specify a command"
} else
{
  switch ($args[0])
  {
    "build"
    { Compile 
    }
    "run"
    { Run 
    }
    "mesh"
    {
      if (!$args[1])
      {
        Write-Output "Insert mesh dimension (2 or 3)D"
      } else
      {
        CompileMesh($args[1])
      }
    }
    "clear"
    {
      Remove-Item -Path build -Force
    }
    "docker_create"
    {
      if (!$args[1])
      {
        Write-Output "Specify a shared folder path"
      } else
      {
        $source_dir = $args[1]
        $cmd =  "docker container create -i -t --name deal.ii -p 3000 --mount type=bind,source=" + $source_dir + ",target=/home/dealii dealii pwsh"
        
        Write-Output $cmd
        Invoke-Expression $cmd
        
      }
    }
    "docker_start"
    {
      $source_dir = $args[1]
      $cmd = "docker container start -ai deal.ii"
      Write-Output $cmd
      Invoke-Expression $cmd
    }
    "docker_rm"
    {
      $source_dir = $args[1]
      $cmd = "docker container rm deal.ii"
      Write-Output $cmd
      Invoke-Expression $cmd
    }
    default
    { Write-Output "Command not supported" 
    }
  }
}
