<#
    .DESCRIPTION
        An example runbook which gets all the ARM resources using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
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
        Write-Output ($Resource.Name + " - " +  $Resource.ResourceType + " - " +  $Resource.Location) >> AllResources.txt
    }
    Write-Output ("") >> AllResources.txt
    }

# Envia e-mail com o arquivo anexo!
$data = (Get-Date).ToString()
[string]$corpoemail = “Report Azure”
$assunto = “Report Azure”

# Enviando e-mail com o relatório a partir do Office 365, dessa forma é necessário fazer a autenticação via TLS, utilize um e-mail valido, altere os campos em negrito com e-mail e senha
$secpasswd = ConvertTo-SecureString “Clara@2018” -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential (“no-reply@claranet.com.br”, $secpasswd)
Send-MailMessage -To “Marcelo Costa <marcelo.costa@br.clara.net>” -SmtpServer “smtp.office365.com” -Credential $mycreds -UseSsl $assunto -Port “587” -Body $corpoemail -From “No Reply - Claranet Brasil <no-reply@claranet.com.br>” -BodyAsHtml -Attachments AllResources.txt