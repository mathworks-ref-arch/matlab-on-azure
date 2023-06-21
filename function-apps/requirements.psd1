<#
 This file contains the modules required by the run.ps1 script.
 It enables modules to be automatically managed by the Functions service.
 See https://aka.ms/functionsmanageddependency for additional information.
#>
@{
 'Az.Compute' = '4.*'
 'Az.Accounts' = '2.*'
 'Az.Resources' = '5.*'
 }
