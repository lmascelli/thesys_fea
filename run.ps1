clear

function TestBuild() {
  if (Test-Path -PathType Container -Path build) {
    return $True
  }
  else {
    return $False
  }
}

if (!$args[0]) {
  Write-Output "Specify a command"
}
else {
  switch ($args[0]) {
    "build" { $BUILD_COMMAND = $True }
    "run" { $RUN_COMMAND = $True }
    default { Write-Output "Command not supported" }
  }
}
