from sqlalchemy import create_engine, Column, Integer, String, Numeric, DateTime, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

Base = declarative_base()

# First, we define the models for our database tables using SQLAlchemy's declarative base. Each class represents a table in the database, and the attributes of the class represent the columns of the table.
class Teleso(Base):
    __tablename__ = 'Teleso' # The name of the table in the database
    __table_args__ = {"schema": "public"} # This specifies that the table belongs to the "public" schema in the database
    id = Column(Integer, primary_key=True, name="id_tel")
    name = Column(String(25), nullable=False, unique=True, name="nazev")
    symbol = Column(String(5), nullable=True)
    id_type_obj = Column(Integer, nullable=False, name="id_typ_tel")
    mean = Column(Numeric, nullable=False, name="prumer_(km)")
    mass = Column(Numeric, nullable=False, name="hmotnost_(kg)")
    density = Column(Numeric, nullable=True, name="hustota_(g/cm^(3))")
    gravity = Column(Numeric, nullable=False, name="gravitace_(m/s^(2))")
    min_t = Column(Numeric, nullable=True, name="min_teplota_(K)")
    mean_t = Column(Numeric, nullable=True, name="prum_teplota_(K)")
    max_t = Column(Numeric, nullable=True, name="max_teplota_(K)")
    rotation = Column(Numeric, nullable=True, name="rychlost_rotace_(km/h)")
    period = Column(Numeric, nullable=False, name="perioda_(d)")
    id_mother_star = Column(Integer, nullable=False, name="id_mat_hve")
    id_mother_planet = Column(Integer, nullable=False, name="id_pla")
    
class Teleso_action(Base):
    __tablename__ = 'teleso_action'
    __table_args__ = {"schema": "public"}
    id = Column(Integer, primary_key=True, autoincrement=True)
    id_obj = Column(Integer, nullable=False,name="id_tel")
    name = Column(String(25), nullable=False, name="nazev")
    date = Column(DateTime, default=func.now(), name="datum")
    action = Column(String(6), nullable=False, name="akce")
    user_ = Column(String(30), nullable=False)

# Database connection
def Connection(username, password):
    global engine
    engine = create_engine(f'postgresql://{username}:{password}@localhost:5432/postgres')
    print('connected')

# Creating the tables in the database
def create_tables(engine):
    Base.metadata.create_all(engine)
    print('Tables created')

# Creating a session to interact with the database
def create_session(engine):
    global session
    Session = sessionmaker(bind=engine)
    session = Session()

# Counting the number of objects in the Teleso table to assign a new ID for a new object. This function queries all objects and returns their count, which is used to set the ID of a new object when inserting it into the database.
def Count_objects():
    try:
        objects = session.query(Teleso).all()
    finally:
        session.close()
        return len(objects)

# Inserting a new object into the Teleso table. This function takes various parameters related to the object being inserted, creates a new instance of the Teleso class, and adds it to the session. It also logs the action in the Teleso_action table, recording the name of the object, the date of the action, the type of action (INSERT), and the user who performed it. If any error occurs during this process, it rolls back the transaction and prints an error message.    
def Insert_object(name, symbol, id_type_obj, mean, mass, density, gravity, min_t, mean_t, max_t, rotation, period, id_mother_star, id_mother_planet, user):
    try:
        teleso = Teleso(id=Count_objects()+1, name=name, symbol=symbol, id_type_obj=id_type_obj, mean=mean, mass=mass, density=density, 
                        gravity=gravity, min_t=min_t, mean_t=mean_t, max_t=max_t, rotation=rotation, period=period, id_mother_star=id_mother_star, id_mother_planet=id_mother_planet)
        session.add(teleso)
        session.commit()
        teleso_action = Teleso_action(id_obj=teleso.id, name=teleso.name, date = datetime.now(), action='INSERT',user_=user)
        session.add(teleso_action)
        session.commit()
        print("New object added to table")
    except Exception as e:
        session.rollback()
        print(f"Error: {e}")
    finally:
        session.close()

# Displaying all objects in the Teleso table. This function queries all objects and prints their name and mean diameter. It ensures that the session is closed after the operation is completed.
def Show_objects():
    try:
        objects = session.query(Teleso).all()
        for object in objects:
            print(f"Object: {object.name}, Mean: {round(object.mean,0)} km")
    finally:
        session.close()

# Function to transfer mean diameter from one object to another. This function takes the names of two objects, the amount of mean diameter to transfer, and the user performing the action. It checks if both objects exist and if the first object has enough mean diameter to transfer. If the checks pass, it updates
def Mean_change(name1, name2, count, user):
    try:
        obj1 = session.query(Teleso).filter(Teleso.name == name1).first()
        obj2 = session.query(Teleso).filter(Teleso.name == name2).first()
        if not obj1 or not obj2: 
            raise ValueError("Object doesn't exists")
        if obj1.mean < count: 
            raise ValueError(f"Object {obj1} have small mean.")
        obj1.mean -= count
        obj2.mean += count
        action1 = Teleso_action(id_obj=obj1.id, name=obj2.name, date = datetime.now(), action='UPDATE', user_=user)
        action2 = Teleso_action(id_obj=obj2.id, name=obj2.name, date = datetime.now(), action='UPDATE', user_=user)
        session.add(action1)
        session.add(action2)
        session.commit()
        print("Mean transaction has been completed.")
    except Exception as e:
        session.rollback()
        print(f"Chyba: {e}")
    finally:
        session.close()

# Usage example
Connection('postgres','patrik123')
create_tables(engine)
create_session(engine)

# List objects and their diameters
print(Show_objects())

# Inserting an object into the database
#Insert_object(name='Mars2', symbol=None, id_type_obj=9, mean=6792.4, mass=6.4185*pow(10,23), density=3.933, gravity=3.69, min_t=130, mean_t=210, max_t=308, rotation=868.22, period=1.026, id_mother_star=1, id_mother_planet=None, user='patricek')
#print(Show_objects())

# Diameter transfer
#Mean_change('Jupiter', 'Merkur', 100000, 'patricek')
#print(Show_objects())
#Mean_change('Merkur', 'Jupiter', 100000, 'patricek')
#print(Show_objects())
