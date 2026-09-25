# Google Play Store Data Safety & Privacy Form Guide

**Application Name:** MyExpense  
**Package Name:** `com.myexpense.app`  
**Target OS:** Android 5.0+ (API Level 21+)  

---

## 1. Google Play Data Safety Form Questionnaire Answers

### A. Data Collection and Security
- **Does your app collect or share any of the required user data types?**  
  👉 **YES**
- **Is all of the user data collected by your app encrypted in transit?**  
  👉 **YES** (All external network traffic uses TLS/HTTPS encryption).
- **Do you provide a way for users to request that their data be deleted?**  
  👉 **YES** (Users can purge data in Settings or clear app data via Android OS Settings).

---

## 2. Detailed Data Type Declarations

| Data Category | Data Type | Collected? | Shared? | Processing Location | Purpose |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Financial Info** | Financial Transactions, Expense Entries, Budgets | **Yes** | **No** | Local Device Only | App Functionality (Expense Tracking & Budgeting) |
| **Location** | Approximate & Precise Location | **Yes** | **No** | Local Device Only | App Functionality (Geofence Location Reminders & Map Pins) |
| **Photos & Videos** | Receipt Photos & Images | **Yes** | **No** | Local Device Only | App Functionality (OCR Receipt Scanning & Slip Attachments) |
| **Files & Docs** | PDF Receipt Documents | **Yes** | **No** | Local Device Only | App Functionality (PDF Receipt Import & OCR Processing) |
| **Messages** | SMS Messages | **Yes** | **No** | Local Device Only | App Functionality (Automated Bank SMS Expense Categorization) |
| **Personal Info** | Name & Email (Google Sign-In) | **Yes** | **No** | Local Device / Secure Auth | Account Management & Authentication |

---

## 3. High-Risk Android Permission Declarations & Justifications

### 1. SMS Permission (`android.permission.RECEIVE_SMS`, `android.permission.READ_SMS`)
- **Use Case Category:** Financial Transaction & Expense Management
- **Justification for Google Play Review:**  
  MyExpense uses SMS permissions strictly to detect bank debit/credit card alerts and payment receipt notifications sent by verified financial institutions. The app parses transaction amounts, dates, and merchant titles **entirely on-device** to generate draft expense entries. Personal messages and non-financial SMS messages are ignored completely. SMS data is never uploaded to remote servers or shared with any third party.

### 2. Location Permission (`android.permission.ACCESS_FINE_LOCATION`, `android.permission.ACCESS_BACKGROUND_LOCATION`)
- **Use Case Category:** Geofencing & Location-Based Reminders
- **Justification for Google Play Review:**  
  MyExpense requests location access to display OpenStreetMap location pickers and maintain local geofences around commercial venues (Petrol Stations, Supermarkets, Markets). When a user leaves a designated zone, the app generates a local push notification reminding them to log their expense. Location data is processed locally on the device and is never broadcasted to tracking networks.

### 3. Camera Permission (`android.permission.CAMERA`)
- **Use Case Category:** Document & Receipt Scanning
- **Justification for Google Play Review:**  
  Allows users to take photos of paper receipts, store bills, and vouchers. Google ML Kit text recognition extracts purchase items, amounts, date, and merchant name on-device.

---

## 4. Privacy Policy URLs for Play Console

When submitting to Google Play Console, paste the following URLs into the **App Content > Privacy Policy** field:

- **Markdown Version:** `https://github.com/tafaisalkhan/my_expense/blob/main/private.md`
- **HTML Web Version:** `https://tafaisalkhan.github.io/my_expense/private.html` (or hosted web link)
