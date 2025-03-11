# Connect to Microsoft Graph with the necessary permissions
Connect-MgGraph -Scopes 'Application.Read.All'

# Set the threshold for expiration alerts (default: 30 days)
$DaysUntilExpiration = 30
$Now = Get-Date

# List of application Object IDs to check (Replace with your own App Registration Object IDs)
$AppIdsToCheck = @(
    'Replace_With_Your_App_Object_ID1',
    'Replace_With_Your_App_Object_ID2',
    'Replace_With_Your_App_Object_ID3'
)

# Email Configuration (Replace with your SMTP details)
$SMTPServer = "Replace_With_SMTP_Server"
$SMTPFromAddress = "Replace_With_Sender_Email"
$SMTPToAddress = @("Replace_With_Recipient_Email1", "Replace_With_Recipient_Email2")

# Retrieve applications by their IDs
$Applications = Get-MgApplication -All | Where-Object { $AppIdsToCheck -contains $_.Id }

# Initialize log collection
$Logs = @()

foreach ($App in $Applications) {
    $AppName = $App.DisplayName
    $AppID   = $App.Id
    $ApplID  = $App.AppId

    # Retrieve application credentials
    $AppCreds = Get-MgApplication -ApplicationId $AppID | Select-Object PasswordCredentials, KeyCredentials

    $Secrets = $AppCreds.PasswordCredentials
    $Certs   = $AppCreds.KeyCredentials

    # Check secrets
    foreach ($Secret in $Secrets) {
        $StartDate  = $Secret.StartDateTime
        $EndDate    = $Secret.EndDateTime
        $SecretName = $Secret.DisplayName

        $RemainingDaysCount = ($EndDate - $Now).Days

        if ($RemainingDaysCount -le $DaysUntilExpiration -and $RemainingDaysCount -ge 0) {
            $ExpiryAlert = 'Secret expires in less than 30 days'

            # Log entry
            $Logs += [PSCustomObject]@{
                'ApplicationName'        = $AppName
                'ApplicationID'          = $ApplID
                'CredentialType'         = "Secret"
                'CredentialName'         = $SecretName
                'StartDate'              = $StartDate
                'EndDate'                = $EndDate
                'ExpiryAlert'            = $ExpiryAlert
            }
        }
    }

    # Check certificates
    foreach ($Cert in $Certs) {
        $StartDate = $Cert.StartDateTime
        $EndDate   = $Cert.EndDateTime
        $CertName  = $Cert.DisplayName

        $RemainingDaysCount = ($EndDate - $Now).Days

        if ($RemainingDaysCount -le $DaysUntilExpiration -and $RemainingDaysCount -ge 0) {
            $ExpiryAlert = 'Certificate expires in less than 30 days'

            # Log entry
            $Logs += [PSCustomObject]@{
                'ApplicationName'        = $AppName
                'ApplicationID'          = $ApplID
                'CredentialType'         = "Certificate"
                'CredentialName'         = $CertName
                'StartDate'              = $StartDate
                'EndDate'                = $EndDate
                'ExpiryAlert'            = $ExpiryAlert
            }
        }
    }
}

# Function to send email alert
function Send-ResultEmail {
    param([system.collections.arraylist]$result_array, [array]$all_app_names)

    $today = Get-Date -format "dddd, MMMM dd, yyyy"
    $emailto = $SMTPToAddress
    $emailfrom = $SMTPFromAddress
    $emailsub = "Azure AD Apps: Secrets and Certificates Expiring Soon"

    if ($result_array.Count -eq 0) {
        $htmlstring = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; font-size: 14px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; font-weight: bold; }
    </style>
</head>
<body>
    <p><b>No expiring credentials found for the following Azure AD Apps in the next 30 days:</b></p>
    <ul>
"@
        foreach ($appName in $all_app_names) {
            $htmlstring += "<li>$appName</li>"
        }

        $htmlstring += @"
    </ul>
</body>
</html>
"@
    } else {
        $htmlstring = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; font-size: 14px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; font-weight: bold; }
    </style>
</head>
<body>
    <p><b>The following credentials are expiring soon:</b></p>
    <table>
        <tr>
            <th>Application Name</th>
            <th>Application ID</th>
            <th>Credential Type</th>
            <th>Credential Name</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Expiry Alert</th>
        </tr>
"@
        foreach ($obj in $result_array) {
            $htmlstring += @"
            <tr>
                <td>$($obj.ApplicationName)</td>
                <td>$($obj.ApplicationID)</td>
                <td>$($obj.CredentialType)</td>
                <td>$($obj.CredentialName)</td>
                <td>$($obj.StartDate)</td>
                <td>$($obj.EndDate)</td>
                <td>$($obj.ExpiryAlert)</td>
            </tr>
"@
        }

        $htmlstring += @"
    </table>
</body>
</html>
"@
    }

    Send-MailMessage -From $emailfrom -To $emailto -Subject $emailsub -BodyAsHtml -Body $htmlstring -SmtpServer $SMTPServer
}

# Collect all application names
$AllAppNames = $Applications | Select-Object -ExpandProperty DisplayName

# Send the email
Send-ResultEmail -result_array $Logs -all_app_names $AllAppNames

# Disconnect from Microsoft Graph
Disconnect-MgGraph
