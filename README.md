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
   git clone https://github.com/YOUR-USERNAME/AzureAD-Credential-Expiry-Monitor.git
   cd AzureAD-Credential-Expiry-Monitor
