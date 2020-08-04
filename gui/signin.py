import mysql
import mysql.connector
from PyQt5 import QtCore, QtGui, QtWidgets

myDB = mysql.connector.connect(
    host="localhost",
    user="root",
    database="foofledb"
)

myCursor = myDB.cursor()

typeError = ""
result = 0


class signin(object):

    def __init__(self):
        pass

    def button_sign_in(self, username, password):
        args = (username, password, result, typeError)
        resProc = myCursor.callproc('sign_in', args)
        print("hello")
        if resProc[2] == 0:
            print(resProc[3])
        else:
            print("successfully")

    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(800, 600)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.username = QtWidgets.QLineEdit(self.centralwidget)
        self.username.setGeometry(QtCore.QRect(310, 210, 211, 51))
        self.username.setObjectName("username")
        self.password = QtWidgets.QLineEdit(self.centralwidget)
        self.password.setGeometry(QtCore.QRect(310, 300, 211, 51))
        self.password.setObjectName("password")
        self.label = QtWidgets.QLabel(self.centralwidget)
        self.label.setGeometry(QtCore.QRect(210, 210, 71, 41))
        self.label.setObjectName("label")
        self.label_2 = QtWidgets.QLabel(self.centralwidget)
        self.label_2.setGeometry(QtCore.QRect(210, 300, 71, 51))
        self.label_2.setObjectName("label_2")
        self.bottonSignin = QtWidgets.QPushButton(self.centralwidget)
        self.bottonSignin.setGeometry(QtCore.QRect(360, 450, 93, 28))
        self.bottonSignin.setObjectName("bottonSignin")
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 800, 26))
        self.menubar.setObjectName("menubar")
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)



        self.retranslateUi(MainWindow)
        self.bottonSignin.clicked.connect(signin.button_sign_in)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.label.setText(_translate("MainWindow", "Username:"))
        self.label_2.setText(_translate("MainWindow", "Password:"))
        self.bottonSignin.setText(_translate("MainWindow", "Sign-in"))


if __name__ == "__main__":
    import sys

    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    ui = signin()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())
