<#
    .DESCRIPTION
        An example runbook which gets all the ARM resources using the Run As Account

    .NOTES
        AUTHOR: Marcelo Costa
        LASTEDIT: 28/06/2018
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Get all ARM resources from all resource groups
$ResourceGroups = Get-AzureRmResourceGroup 

foreach ($ResourceGroup in $ResourceGroups)
{    
    Write-Output ("Exibindo recursos no resource group " + $ResourceGroup.ResourceGroupName)
    $Resources = Get-AzureRmResource -ResourceGroupName $ResourceGroup.ResourceGroupName | Select Name, ResourceType, Location
    ForEach ($Resource in $Resources)
    {
        Write-Output ($Resource.Name + "," +  $Resource.ResourceType + "," +  $Resource.Location) >> AllResources.txt
    }
    Write-Output ("") >> AllResources.txt
    }

# Envia e-mail com o arquivo anexo!
$data = (Get-Date).ToString()
[string]$corpoemail = “Report Azure”
$assunto = “Report Azure”

# Enviando e-mail com o relatório a partir do Office 365, dessa forma é necessário fazer a autenticação via TLS, utilize um e-mail valido, altere os campos em negrito com e-mail e senha
$secpasswd = ConvertTo-SecureString “” -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential (“”, $secpasswd)
Send-MailMessage -To “ <>” -SmtpServer “” -Credential $mycreds -UseSsl $assunto -Port “587” -Body $corpoemail -From “ <>” -BodyAsHtml -Attachments AllResources.txt
