from sqlalchemy import create_engine, Column, Integer, String, Numeric, DateTime, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

Base = declarative_base()

#nejdřív si uděláme modely
class Teleso(Base):
    __tablename__ = 'Teleso'
    __table_args__ = {"schema": "public"}

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

#připojení k databázi
def Connection(username, password):
    global engine
    engine = create_engine(f'postgresql://{username}:{password}@localhost:5432/postgres')
    print('connected')

# Vytvoření tabulek
def create_tables(engine):
    Base.metadata.create_all(engine)
    print('Tables created')

#vytvoření session
def create_session(engine):
    global session
    Session = sessionmaker(bind=engine)
    session = Session()

def Count_objects():
    try:
        objects = session.query(Teleso).all()
    finally:
        session.close()
        return len(objects)
    
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

def Show_objects():
    try:
        objects = session.query(Teleso).all()
        for object in objects:
            print(f"Object: {object.name}, Mean: {round(object.mean,0)} km")
    finally:
        session.close()

def Mean_change(name1, name2, count, user):
    try:
        obj1 = session.query(Teleso).filter(Teleso.name == name1).first()
        obj2 = session.query(Teleso).filter(Teleso.name == name2).first()

        if not obj1 or not obj2: raise ValueError("Object doesn't exists")
        if obj1.mean < count: raise ValueError(f"Object {obj1} have small mean.")

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

# Příklad použití
Connection('postgres','patrik123')
create_tables(engine)
create_session(engine)

#výpis těles a jejich průměrů
print(Show_objects())
#vložení objektu do databáze
#Insert_object(name='Mars2', symbol=None, id_type_obj=9, mean=6792.4, mass=6.4185*pow(10,23), density=3.933, gravity=3.69, min_t=130, mean_t=210, max_t=308, rotation=868.22, period=1.026, id_mother_star=1, id_mother_planet=None, user='patricek')
#print(Show_objects())
#převod průměru
#Mean_change('Jupiter', 'Merkur', 100000, 'patricek')
#print(Show_objects())
#Mean_change('Merkur', 'Jupiter', 100000, 'patricek')
#print(Show_objects())
