from datetime import datetime, timedelta
from typing import Optional, List
import os
import shutil

from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import sessionmaker, relationship, declarative_base
from passlib.context import CryptContext
from jose import JWTError, jwt
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

# -------------------------------
# Configuración
# -------------------------------
DATABASE_URL = os.getenv("DATABASE_URL", "mysql+pymysql://root:@localhost/paquexpress_db")
SECRET_KEY = os.getenv("SECRET_KEY", "020614")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# -------------------------------
# Modelos de Base de Datos
# -------------------------------
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(80), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=True)

class Delivery(Base):
    __tablename__ = "deliveries"
    id = Column(Integer, primary_key=True, index=True)
    destination_address = Column(String(255), nullable=False)
    recipient = Column(String(255), nullable=True)
    assigned_to = Column(Integer, ForeignKey("users.id"), nullable=True)
    delivered = Column(Boolean, default=False)
    delivered_at = Column(DateTime, nullable=True)
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    photo_path = Column(String(255), nullable=True)
    notes = Column(Text, nullable=True)

    user = relationship("User", backref="deliveries")

class PhotoRecord(Base):
    __tablename__ = "photos"
    id = Column(Integer, primary_key=True)
    delivery_id = Column(Integer, ForeignKey("deliveries.id"))
    path = Column(String(255))
    uploaded_at = Column(DateTime, default=datetime.utcnow)

Base.metadata.create_all(engine)

# -------------------------------
# Esquemas (Pydantic v2)
# -------------------------------
class UserSchema(BaseModel):
    id: int
    username: str

    model_config = {"from_attributes": True}

class DeliverySchema(BaseModel):
    id: int
    destination_address: str
    recipient: Optional[str]
    assigned_to: Optional[int]
    delivered: bool
    delivered_at: Optional[datetime]
    lat: Optional[float]
    lon: Optional[float]
    photo_path: Optional[str]
    notes: Optional[str]

    model_config = {"from_attributes": True}

# -------------------------------
# App
# -------------------------------
app = FastAPI()
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------
# Autenticación y helpers
# -------------------------------
def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_user_by_username(db, username: str):
    return db.query(User).filter(User.username == username).first()

def authenticate_user(db, username: str, password: str):
    user = get_user_by_username(db, username)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(status_code=401, detail="No autorizado")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    db = SessionLocal()
    user = get_user_by_username(db, username)
    db.close()

    if user is None:
        raise credentials_exception

    return user

# -------------------------------
# Endpoints
# -------------------------------
@app.post("/auth/register")
def register(username: str = Form(...), password: str = Form(...), full_name: str = Form(None)):
    db = SessionLocal()
    try:
        if get_user_by_username(db, username):
            raise HTTPException(status_code=400, detail="Usuario ya existe")

        user = User(
            username=username,
            hashed_password=get_password_hash(password),
            full_name=full_name
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        return {"msg": "Usuario creado", "user": {"id": user.id, "username": user.username}}
    finally:
        db.close()

@app.post("/auth/login")
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    db = SessionLocal()
    try:
        user = authenticate_user(db, form_data.username, form_data.password)
        if not user:
            raise HTTPException(status_code=400, detail="Usuario o contraseña incorrecta")

        access_token = create_access_token(data={"sub": user.username})
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {"id": user.id, "username": user.username}
        }
    finally:
        db.close()

@app.get("/deliveries/assigned", response_model=List[DeliverySchema])
def get_assigned_deliveries(current_user: User = Depends(get_current_user)):
    db = SessionLocal()
    try:
        deliveries = db.query(Delivery).filter(Delivery.assigned_to == current_user.id).all()
        return deliveries
    finally:
        db.close()

@app.post("/deliveries/{delivery_id}/deliver")
async def deliver_package(
    delivery_id: int,
    lat: float = Form(...),
    lon: float = Form(...),
    description: str = Form(""),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
):
    db = SessionLocal()
    try:
        delivery = db.query(Delivery).filter(
            Delivery.id == delivery_id,
            Delivery.assigned_to == current_user.id
        ).first()

        if not delivery:
            raise HTTPException(status_code=404, detail="Entrega no encontrada o no asignada a este agente")

        os.makedirs("uploads", exist_ok=True)
        filename = f"{datetime.utcnow().strftime('%Y%m%d%H%M%S')}_{file.filename}"
        path = os.path.join("uploads", filename)

        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        foto = PhotoRecord(delivery_id=delivery_id, path=path)
        db.add(foto)

        delivery.delivered = True
        delivery.delivered_at = datetime.utcnow()
        delivery.lat = lat
        delivery.lon = lon
        delivery.photo_path = path
        delivery.notes = description

        db.commit()

        return {"msg": "Entrega registrada", "delivery": DeliverySchema.model_validate(delivery)}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()

@app.get("/deliveries/", response_model=List[DeliverySchema])
def list_all_deliveries():
    db = SessionLocal()
    try:
        return db.query(Delivery).all()
    finally:
        db.close()
