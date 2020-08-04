import mysql
import mysql.connector
import prettytable
from prettytable import PrettyTable


myDB = mysql.connector.connect(
    host="localhost",
    user="root",
    database="foofledb"
)

print("Welcome to Foofle \n")
print("For guidance Enter 'help'")

helpUser0 = "For sign in account : sign in \n" \
            "For create an account : creat account \n" \
            "For exit from Foofle : exit foofle"

helpUser1 = "For get news : get news \n" \
           "For get my account information : get my account information \n" \
           "For get other account information : get other account information \n" \
           "For edit my account information : edit my account information \n" \
           "For delete my account : delete my account \n" \
           "For send email : send email \n" \
           "For get my inbox : get my inbox \n" \
           "For get my sent box : get my sent box \n" \
           "For read email : read email \n" \
           "For delete email : delete email \n" \
            "For Exit my account : exit my account"

res = True
typeError = ""


myCursor = myDB.cursor()

exitFoofle = False

while not exitFoofle:
    input_string = input()
    if input_string == "help":
        print(helpUser0)
    elif input_string == "create account":
        print("Enter your username : ")
        username = input()
        print("Enter your password : ")
        password = input()
        print("Enter your phone number to save in system data : ")
        s_phone_number = input()
        print("Enter your first name, last name, nick name : ")
        first_name = input()
        last_name = input()
        nick_name = input()
        print("Enter your national id :")
        national_id = input()
        print("Enter your birth date : ")
        birth_date = input()
        print("Enter your phone number to save in personal data : ")
        p_phone_number = input()
        print("Default access status to your personal data?! (yes / no)")
        default_access_status = input()
        print("Enter your address : ")
        address = input()
        args = (username, password, s_phone_number, first_name, last_name, nick_name, national_id, birth_date, p_phone_number, default_access_status, address, res, typeError)
        resProc = myCursor.callproc("create_account", args)
        myDB.commit()
        if resProc[11] == 0:
            print(resProc[12])
        else:
            print('create account successfully!')

            print("Do you want to add to special access status?! (yes / no)")
            s = input()
            if s == "yes":
                print("how many username accounts you add in special access?")
                n = input()
                for i in range(0, int(n)):
                    print("Enter wanted username :")
                    requested_username = input()
                    print("allow access?! (always / never)")
                    allow_access = input()
                    args = (username, requested_username, allow_access, res, typeError)
                    resProc = myCursor.callproc("insert_special_access", args)
                    myDB.commit()
                    if resProc[3] == 0:
                        print(resProc[4])
                    else:
                        print("successfully!")

    elif input_string == "sign in":
        print("Enter your username : ")
        username = input()
        print("Enter your password : ")
        password = input()
        args = (username, password, res, typeError)
        resProc = myCursor.callproc("sign_in", args)
        myDB.commit()

        if resProc[2] == 0:
            print(resProc[3])

        else:
            exitMyAccount = False
            print("sign in is successfully!")
            myUsername = username

            while not exitMyAccount:
                print("For guidance Enter 'help'")
                input_string = input()

                if input_string == "help":
                    print(helpUser1)

                elif input_string == "get my account information":
                    args = (myUsername, res)
                    resProc = myCursor.callproc("get_my_account_information", args)
                    myDB.commit()
                    table = PrettyTable()
                    table.field_names = ['Username', 'Date create', 'System phone number', 'First name', 'Last name', 'Nick name', 'National id', 'Birth date', 'Personal phone number', 'Default access status', 'Address']
                    for result in myCursor.stored_results():
                        rows = result.fetchall()
                    for row in rows:
                        table.add_row(row)
                    print(table)

                elif input_string == "get other account information":
                    print("Enter search username: ")
                    searchUsername = input()
                    args = (myUsername, searchUsername, res, typeError)
                    resProc = myCursor.callproc("get_other_account_information", args)
                    myDB.commit()
                    table = PrettyTable()
                    table.field_names = ['Username',  'First name', 'Last name', 'Nick name', 'National id', 'Birth date', 'Personal phone number', 'Default access status', 'Address']
                    for result in myCursor.stored_results():
                        rows = result.fetchall()
                    for row in rows:
                        table.add_row(row)
                    print(table)

                elif input_string == "edit my account information":
                    print("Edit password?! (for edit your password Enter new password, if not Enter '-')")
                    nPassword = input()
                    print("Edit first name?! (for edit your first name Enter new first name, if not Enter '-')")
                    nFirstName = input()
                    print("Edit last name?! (for edit your last name Enter new last name, if not Enter '-')")
                    nLastName = input()
                    print("Edit nick name?! (for edit your nick name Enter new nick name, if not Enter '-')")
                    nNickName = input()
                    print("Edit national id?! (for edit your national id Enter new national id, if not Enter '-')")
                    nNationalID = input()
                    print("Edit birth date?! (for edit your birth date Enter new birth date, if not Enter '-')")
                    nBirthDate = input()
                    print("Edit system phone number?! (for edit Enter new phone number, if not Enter '-')")
                    nSPhoneNumber = input()
                    print("Edit personal phone number?! (for edit Enter new phone number, if not Enter '-')")
                    nPPhoneNumber = input()
                    print("Edit default access status?! (for edit Enter new default access status, if not Enter '-')")
                    nDefaultAccessStatus = input()
                    print("Edit address?! (for edit Enter new address, if not Enter '-')")
                    nAddress = input()
                    args = (myUsername, nPassword, nFirstName, nLastName, nNickName, nNationalID, nBirthDate, nSPhoneNumber, nPPhoneNumber, nDefaultAccessStatus, nAddress, res, typeError)
                    resProc = myCursor.callproc("edit_account", args)
                    myDB.commit()
                    if resProc[11] == 0:
                        print(resProc[12])
                    else:
                        print("edit is successfully!")

                elif input_string == "delete my account":
                    args = (myUsername, res, typeError)
                    resProc = myCursor.callproc("delete_account", args)
                    myDB.commit()
                    print("Your account was deleted!")

                elif input_string == "send email":
                    print("To : (Max Enter 3 email address)\n"
                          "if not Enter '-'")
                    print("receiver1 :")
                    receiver1 = input()
                    print("receiver2 :")
                    receiver2 = input()
                    print("receiver3 :")
                    receiver3 = input()
                    print("To (cc): (Max Enter 3 email address)")
                    print("receiverCC1 :")
                    receiverCC1 = input()
                    print("receiverCC2 :")
                    receiverCC2 = input()
                    print("receiverCC3 :")
                    receiverCC3 = input()

                    print("subject: ")
                    subject = input()
                    print("context: ")
                    context = input()
                    uReceiver1 = receiver1.split("@")
                    uReceiver2 = receiver2.split("@")
                    uReceiver3 = receiver3.split("@")
                    uReceiverCC1 = receiverCC1.split("@")
                    uReceiverCC2 = receiverCC2.split("@")
                    uReceiverCC3 = receiverCC3.split("@")

                    args = (myUsername, uReceiver1[0], uReceiver2[0], uReceiver3[0], uReceiverCC1[0], uReceiverCC2[0], uReceiverCC3[0], subject, context, res, typeError)
                    resProc = myCursor.callproc("send_email", args)
                    myDB.commit()
                    if resProc[9] == 0:
                        print(resProc[10])
                    else:
                        print("email send!")

                elif input_string == "get my inbox":
                    print("Which page of inbox?!")
                    pageNumber = input()
                    args = (myUsername, pageNumber)
                    resProc = myCursor.callproc("get_inbox", args)
                    myDB.commit()
                    table = PrettyTable()
                    table.field_names = ["Email id", "From", "Subject", "Send time", "Context", "Read status"]
                    for result in myCursor.stored_results():
                        rows = result.fetchall()
                    for row in rows:
                        table.add_row(row)
                    print(table)

                elif input_string == "get my sent box":
                    print("Which page of sent box?!")
                    pageNumber = input()
                    args = (myUsername, pageNumber)
                    resProc = myCursor.callproc("get_sentBox", args)
                    myDB.commit()
                    table = PrettyTable()
                    table.field_names = ["Email id", "Subject", "Send time", "Context", "Read status"]
                    for result in myCursor.stored_results():
                        rows = result.fetchall()
                    for row in rows:
                        table.add_row(row)
                    print(table)

                elif input_string == "read email":
                    print("Which email?! (Enter email id)")
                    emailID = input()
                    args = (myUsername, emailID, res, typeError)
                    resProc = myCursor.callproc("read_email", args)
                    myDB.commit()
                    if resProc[2] == 0:
                        print(resProc[3])
                    else:
                        print("Read email successfully!")

                elif input_string == "delete email":
                    print("Which email?! (Enter email id)")
                    emailID = input()
                    args = (myUsername, emailID, res, typeError)
                    resProc = myCursor.callproc("delete_email", args)
                    myDB.commit()
                    if resProc[2] == 0:
                        print(resProc[3])
                    else:
                        print("Delete email successfully!")

                elif input_string == "get news":
                    args = (myUsername, res)
                    resProc = myCursor.callproc("get_news", args)
                    table = PrettyTable()
                    table.field_names = ["Username", "Time", "Context"]
                    for result in myCursor.stored_results():
                        rows = result.fetchall()
                    for row in rows:
                        table.add_row(row)
                    print(table)
                    myDB.commit()

                elif input_string == "exit my account":
                    exitMyAccount = True
                    print("For guidance Enter 'help'")

                else:
                    print("This instruction incorrect \n"
                          "For guidance Enter 'help'")

    elif input_string == "exit foofle":
        exitFoofle = True

    else:
        print("This instruction incorrect \n"
              "For guidance Enter 'help'")