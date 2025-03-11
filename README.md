# Azure AD Credential Expiry Monitor

## 📌 Overview
This PowerShell script checks **Azure AD application credentials (secrets & certificates)** and sends **email alerts** if they are expiring soon.

## ⚡ Features
✅ Fetches **Azure AD app secrets & certificates**  
✅ Checks **expiration dates**  
✅ Sends **email notifications**  

## 🔧 Requirements
- **Microsoft Graph PowerShell SDK**
- **Permissions**: `Application.Read.All`
- **SMTP access** for email alerts

## 🚀 How to Use
1. **Clone the repository**:
   ```sh
   git clone https://github.com/ShivaprasadARM/AzureAD-Credential-Expiry-Monitoring/blob/main/Check-App-Credential-Expiry.ps1
   cd AzureAD-Credential-Expiry-Monitor


🔧 Instructions to Use This Script
Replace placeholders with your actual values:
"Replace_With_Your_App_Object_ID1" → Your Azure AD App Object IDs
"Replace_With_SMTP_Server" → Your SMTP server address
"Replace_With_Sender_Email" → Your noreply email address
"Replace_With_Recipient_Email1" → The email recipients
Run the script in PowerShell with admin privileges.
Modify $DaysUntilExpiration if you want a different threshold (e.g., 60 days).

🚀 Why This Script Is Helpful
✅ Prevents service disruptions due to expired credentials
✅ Automates security monitoring without manual effort
✅ Sends proactive alerts to the right stakeholders
✅ Fully customizable based on organizational needs
