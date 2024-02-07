import os.path
import serial
import firebase_admin
from firebase_admin import credentials, firestore
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import time

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]

# The ID and range of a sample spreadsheet.
SAMPLE_SPREADSHEET_ID = "1V5EgD187L7MdyHODQ1B2r6obKboc8WH6jzKJiwqIJ6s"
SAMPLE_RANGE_NAME = "Sheet1!A1"

# sensor value import
ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
ser.flush()

# cloud firestore credentials
cred = credentials.Certificate("/home/pi/Downloads/cred.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# user and system details
name = 'system1'
email = "bharathrajnarashiman@gmail.com"
userDataStoreReference = db.collection('dataStore').document(email)
path = ''
delay_firestore = 60
delay_sheets = 30  # Delay for pushing data to Google Sheets

def main():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "credentials.json", SCOPES
            )
            creds = flow.run_local_server(port=3000)
        # Save the credentials for the next run
        with open("token.json", "w") as token:
            token.write(creds.to_json())

    return creds


# Get the permanent path
def getPath():
    try:
        dbRef = userDataStoreReference.get()
        path = dbRef.to_dict()['paths'][name]
        return path
    except Exception as e:
        print('Exception in getting the path', end=" ")
        print(e)
        return False
    

# timestamp function
def get_timestamp():
    t = time.localtime()
    return time.strftime('%Y:%m:%d %H:%M:%S', t)


# Append the data to Google Sheets
def append_data_to_sheets(data, creds):
    try:
        service = build("sheets", "v4", credentials=creds)

        # Call the Sheets API
        sheet = service.spreadsheets()
        value_data = [data["DO"], data["PH"], data["TEMP"], data["TDS"]]
        result = (
            sheet.values()
            .update(spreadsheetId=SAMPLE_SPREADSHEET_ID, range=SAMPLE_RANGE_NAME, valueInputOption="USER_ENTERED",
                    body={"values": value_data})
            .execute()
        )
        return True

    except HttpError as err:
        print(err)
        return err
    
    
# Temporary data set function
def tempSet(data):
    try:
        userDataStoreReference.set({
            name: data
        }, merge=True)
        return True
    except Exception as e:
        print('temporary data storage error', end=" ")
        print(e)
        return False
    

# Permanent data set function for Firestore
def permanent_data_set_firestore(data,path):
    try:
        userDataStoreReference.collection(path).document(
            name).set({get_timestamp(): data}, merge=True)
        return True
    except Exception as e:
        print('Firestore permanent data storage error:', e)
        return False


# Getting the delay time for Firestore
def get_delay_time_firestore():
    try:
        delay_dict = userDataStoreReference.collection(path).document(
            name).collection("systemdetail").document('delay').get().to_dict()
        delay_time = delay_dict['seconds']
        return delay_time
    except Exception as e:
        print('Error in getting the Firestore delay:', e)
        return False


# Separate function for the main loop to handle delays individually
def process_data_loop():
    while True:
        creds = main()
        serial_data = ser.readline().decode().strip().split(',')
        data = {}

        if len(serial_data) > 1:
            # Update database
            data = {"DO": serial_data[0], "TEMP": serial_data[1], "PH": serial_data[2], "TDS": serial_data[3]}
            print(data)

        try:
            # Temporary data push function call
            temp_check = tempSet(data)
            print("Temporary data set:", temp_check)

            # Path get function call
            path = getPath()
            print('Path value:', path)

            # Check for permanent data set for Firestore
            if path:
                # Get the delay for Firestore from function call
                delay_firestore = get_delay_time_firestore()
                print('Firestore Delay time:', delay_firestore)

                # Permanent data set function for Firestore
                permanent_set_check_firestore = permanent_data_set_firestore(data,path)
                print('Firestore Permanent data set check:', permanent_set_check_firestore)

                # Sleep for the Firestore delay before attempting to upload to Google Sheets
                time.sleep(delay_firestore)

            else:
                print('Path not yet defined')

            # Set data into spreadsheets with a fixed delay for Google Sheets
            sheet_upload_data = append_data_to_sheets(data, creds)
            print('Google Sheets Delay time:', delay_sheets)
            print('Data uploaded to sheet => check:', sheet_upload_data)

        except Exception as e:
            print('Exception in main loop:', e)

        finally:
            # Sleep for an additional 30 seconds before the next iteration
            time.sleep(delay_sheets)

if __name__ == '__main__':
    process_data_loop()