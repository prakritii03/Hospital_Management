from flask import Flask,render_template,request,session,redirect,url_for,flash
from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from werkzeug.security import generate_password_hash,check_password_hash
from flask_login import login_user,logout_user,login_manager,LoginManager
from flask_login import login_required,current_user
import json
import os
from dotenv import load_dotenv

load_dotenv()

local_server= True
app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'hmsprojects')

login_manager=LoginManager(app)
login_manager.login_view='login'


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


app.config['SQLALCHEMY_DATABASE_URI']=os.getenv('DATABASE_URL', 'mysql://root:@localhost/hms')
db=SQLAlchemy(app)


class Test(db.Model):
    id=db.Column(db.Integer,primary_key=True)
    name=db.Column(db.String(100))
    email=db.Column(db.String(100))

class User(UserMixin,db.Model):
    id=db.Column(db.Integer,primary_key=True)
    username=db.Column(db.String(50))
    usertype=db.Column(db.String(50))
    email=db.Column(db.String(50),unique=True)
    password=db.Column(db.String(1000))

class Patients(db.Model):
    pid=db.Column(db.Integer,primary_key=True)
    email=db.Column(db.String(50), db.ForeignKey('user.email'))
    name=db.Column(db.String(50))
    gender=db.Column(db.String(50))
    slot=db.Column(db.String(50))
    disease=db.Column(db.String(50))
    time=db.Column(db.String(50),nullable=False)
    date=db.Column(db.String(50),nullable=False)
    dept=db.Column(db.String(50))
    number=db.Column(db.String(50))

class Doctors(db.Model):
    did=db.Column(db.Integer,primary_key=True)
    email=db.Column(db.String(50), db.ForeignKey('user.email'))
    doctorname=db.Column(db.String(50))
    dept=db.Column(db.String(50))

class Trigr(db.Model):
    tid=db.Column(db.Integer,primary_key=True)
    pid=db.Column(db.Integer)
    email=db.Column(db.String(50))
    name=db.Column(db.String(50))
    action=db.Column(db.String(50))
    timestamp=db.Column(db.String(50))

class Billing(db.Model):
    bid=db.Column(db.Integer,primary_key=True)
    pid=db.Column(db.Integer, db.ForeignKey('patients.pid'))
    email=db.Column(db.String(50))
    name=db.Column(db.String(50))
    amount=db.Column(db.Numeric(10, 2))
    status=db.Column(db.String(50), default='Pending')
    timestamp=db.Column(db.DateTime, default=db.func.now())



@app.route('/')
def index():
    return render_template('index.html')

    
@app.route('/doctors',methods=['POST','GET'])
@login_required
def doctors():

    if current_user.usertype != "Doctor":
        flash("Only doctors can register a doctor profile.", "danger")
        return redirect(url_for('index'))

    if request.method=="POST":

        email=request.form.get('email')
        doctorname=request.form.get('doctorname')
        dept=request.form.get('dept')

        query=Doctors(email=email,doctorname=doctorname,dept=dept)
        db.session.add(query)
        db.session.commit()
        flash("Information is Stored","primary")

    return render_template('doctor.html')



@app.route('/patients',methods=['POST','GET'])
@login_required
def patient():
    doct=Doctors.query.all()

    if request.method=="POST":
        email=request.form.get('email')
        name=request.form.get('name')
        gender=request.form.get('gender')
        slot=request.form.get('slot')
        disease=request.form.get('disease')
        time=request.form.get('time')
        date=request.form.get('date')
        dept=request.form.get('dept')
        number=request.form.get('number')
        
        try:
            query=Patients(email=email,name=name,gender=gender,slot=slot,disease=disease,time=time,date=date,dept=dept,number=number)
            db.session.add(query)
            db.session.commit()
            flash("Booking Confirmed","info")
        except Exception as e:
            db.session.rollback()
            err_msg = str(e)
            known_errors = [
                "Appointment date cannot be in the past!",
                "Phone number must be exactly 10 digits!",
                "Invalid email address format!",
                "No doctors are available for the selected department!",
                "This slot is fully booked for the selected department!"
            ]
            matched_msg = None
            for msg in known_errors:
                if msg in err_msg:
                    matched_msg = msg
                    break
            
            if matched_msg:
                flash(matched_msg, "danger")
            else:
                import re
                match = re.search(r"1644,\s*['\"]([^'\"]+)['\"]", err_msg)
                if match:
                    flash(match.group(1), "danger")
                else:
                    flash("An error occurred during booking. Please check your inputs.", "danger")

    return render_template('patient.html',doct=doct)



@app.route('/bookings')
@login_required
def bookings(): 
    em=current_user.email
    if current_user.usertype=="Doctor":
        query=Patients.query.all()
        return render_template('booking.html',query=query)
    else:
        query=Patients.query.filter_by(email=em)
        print(query)
        return render_template('booking.html',query=query)
    


@app.route("/edit/<int:pid>",methods=['POST','GET'])
@login_required
def edit(pid):    
    if request.method=="POST":
        email=request.form.get('email')
        name=request.form.get('name')
        gender=request.form.get('gender')
        slot=request.form.get('slot')
        disease=request.form.get('disease')
        time=request.form.get('time')
        date=request.form.get('date')
        dept=request.form.get('dept')
        number=request.form.get('number')
        
        post=Patients.query.filter_by(pid=pid).first()
        post.email=email
        post.name=name
        post.gender=gender
        post.slot=slot
        post.disease=disease
        post.time=time
        post.date=date
        post.dept=dept
        post.number=number
        
        try:
            db.session.commit()
            flash("Slot is Updated","success")
            return redirect('/bookings')
        except Exception as e:
            db.session.rollback()
            err_msg = str(e)
            known_errors = [
                "Appointment date cannot be in the past!",
                "Phone number must be exactly 10 digits!",
                "Invalid email address format!",
                "No doctors are available for the selected department!",
                "This slot is fully booked for the selected department!"
            ]
            matched_msg = None
            for msg in known_errors:
                if msg in err_msg:
                    matched_msg = msg
                    break
            
            if matched_msg:
                flash(matched_msg, "danger")
            else:
                import re
                match = re.search(r"1644,\s*['\"]([^'\"]+)['\"]", err_msg)
                if match:
                    flash(match.group(1), "danger")
                else:
                    flash("An error occurred during modification. Please check your inputs.", "danger")
            return redirect(url_for('edit', pid=pid))
        
    posts=Patients.query.filter_by(pid=pid).first()
    return render_template('edit.html',posts=posts)



@app.route("/delete/<int:pid>",methods=['POST','GET'])
@login_required
def delete(pid):
    # db.engine.execute(f"DELETE FROM `patients` WHERE `patients`.`pid`={pid}")
    query=Patients.query.filter_by(pid=pid).first()
    db.session.delete(query)
    db.session.commit()
    flash("Slot Deleted Successful","danger")
    return redirect('/bookings')






@app.route('/signup',methods=['POST','GET'])
def signup():
    if request.method == "POST":
        username=request.form.get('username')
        usertype=request.form.get('usertype')
        email=request.form.get('email')
        password=request.form.get('password')
        user=User.query.filter_by(email=email).first()
        if user:
            flash("Email Already Exist","warning")
            return render_template('/signup.html')

        encpassword=generate_password_hash(password)
        myquery=User(username=username,usertype=usertype,email=email,password=encpassword)
        db.session.add(myquery)
        db.session.commit()
        flash("Signup Succes Please Login","success")
        return render_template('login.html')

          

    return render_template('signup.html')

@app.route('/login',methods=['POST','GET'])
def login():
    if request.method == "POST":
        email=request.form.get('email')
        password=request.form.get('password')
        user=User.query.filter_by(email=email).first()

        if user and check_password_hash(user.password, password):
            login_user(user)
            flash("Login Success","primary")
            return redirect(url_for('index'))
        else:
            flash("invalid credentials","danger")
            return render_template('login.html')    





    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash("Logout SuccessFul","warning")
    return redirect(url_for('login'))



@app.route('/test')
def test():
    try:
        Test.query.all()
        return 'My database is Connected'
    except:
        return 'My db is not Connected'
    

@app.route('/details')
@login_required
def details():
    posts=Trigr.query.all()
    # posts=db.engine.execute("SELECT * FROM `trigr`")
    return render_template('trigers.html',posts=posts)


@app.route('/search',methods=['POST','GET'])
@login_required
def search():
    if request.method=="POST":
        query=request.form.get('search')
        dept=Doctors.query.filter_by(dept=query).first()
        name=Doctors.query.filter_by(doctorname=query).first()
        if name or dept:

            flash("Doctor is Available","info")
        else:

            flash("Doctor is Not Available","danger")
    return render_template('index.html')

@app.route('/billing')
@login_required
def billing():
    em=current_user.email
    if current_user.usertype=="Doctor":
        bills = Billing.query.all()
    else:
        bills = Billing.query.filter_by(email=em).all()
    return render_template('billing.html', bills=bills)

@app.route('/billing/pay/<int:bid>')
@login_required
def pay_bill(bid):
    bill = Billing.query.filter_by(bid=bid).first()
    if bill:
        if current_user.usertype == "Doctor" or current_user.email == bill.email:
            bill.status = "Paid"
            db.session.commit()
            flash("Invoice Paid Successfully!", "success")
        else:
            flash("Unauthorized action.", "danger")
    else:
        flash("Invoice not found.", "danger")
    return redirect('/billing')


if __name__ == '__main__':
    app.run(debug=False)