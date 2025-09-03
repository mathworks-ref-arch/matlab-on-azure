<#
This file contains the modules required by the run.ps1 script.
It enables modules to be automatically managed by the Functions service.
See https://aka.ms/functionsmanageddependency for additional information.
Copyright 2023-2025 The MathWorks, Inc.
#>
@{
    'Az.Compute' = '10.*'
    'Az.Accounts' = '5.*'
    'Az.Resources' = '8.*'
}
