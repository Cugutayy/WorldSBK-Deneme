import pandas as pd
import numpy as np
from xgboost import XGBRegressor
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import GridSearchCV, cross_val_score
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
import seaborn as sns

# --- 1) 2024 Superpole ve Race 1 Verileri (Gerçek Veriler) ---
Riders_2024 = [
    "T. RAZGATLIOGLU", "N. BULEGA", "S. REDDING", "S. LOWES",
    "D. AEGERTER", "M. VAN DER MARK", "A. LOCATELLI", "J. REA",
    "A. LOWES", "T. GARDNER", "A. BAUTISTA", "G. GERLOFF",
    "D. PETRUCCI", "M. RINALDI", "A. BASSANI", "B. RAY",
    "I. LECUONA", "F. IANNONE", "T. RABAT", "P. OETTL",
    "A. NORRODIN"
]
Quali2024 = [
    84.629, 85.202, 85.406, 85.492,
    85.528, 85.621, 85.630, 85.638,
    85.644, 85.764, 85.839, 85.895,
    86.167, 86.197, 86.242, 86.393,
    86.529, 86.607, 86.692, 86.815,
    88.488
]
Race1_2024 = [
    85.786, 86.717, 86.757, 87.364,
    87.366, 87.265, 86.951, 86.847,
    86.611, 87.199, 86.658, 86.946,
    87.491, 87.309, 87.689, 87.528,
    87.208, 87.906, 87.784, 86.815,
    89.299
]
Teams_2024 = [
    "ROKiT BMW Motorrad WorldSBK Team", "Aruba.it Racing - Ducati", "Bonovo Action BMW", "Kawasaki Racing Team",
    "Pata Yamaha Prometeon", "ROKiT BMW Motorrad WorldSBK Team", "Pata Yamaha Prometeon", "Pata Yamaha Prometeon",
    "Kawasaki Racing Team", "Team HRC", "Aruba.it Racing - Ducati", "Bonovo Action BMW",
    "Barni Spark Racing Team", "Motocorsa Racing", "Kawasaki Racing Team", "Team HRC",
    "Team HRC", "Go Eleven Ducati", "Motoxracing Yamaha WorldSBK Team", "GMT94 Yamaha",
    "PETRONAS MIE Racing Honda"
]
# Donington 2024 Galibiyet Sayıları (Gerçek Verilere Dayalı)
Past_Wins_Donington = {
    "T. RAZGATLIOGLU": 3,  # 2024 Donington’da 3 galibiyet
    "A. BAUTISTA": 2,      # 2023 Donington’da 2 galibiyet
    "J. REA": 2,           # Tarihsel olarak 2 galibiyet
    "A. LOWES": 1,         # 1 galibiyet
    "N. BULEGA": 0,        # Galibiyet yok
    "S. REDDING": 0,       # Galibiyet yok
    "S. LOWES": 0,         # Galibiyet yok
    "D. AEGERTER": 0,      # Galibiyet yok
    "M. VAN DER MARK": 0,  # Galibiyet yok
    "A. LOCATELLI": 0,     # Galibiyet yok
    "T. GARDNER": 0,       # Galibiyet yok
    "G. GERLOFF": 0,       # Galibiyet yok
    "D. PETRUCCI": 0,      # Galibiyet yok
    "M. RINALDI": 0,       # Galibiyet yok
    "A. BASSANI": 0,       # Galibiyet yok
    "B. RAY": 0,           # Galibiyet yok
    "I. LECUONA": 0,       # Galibiyet yok
    "F. IANNONE": 0,       # Galibiyet yok
    "T. RABAT": 0,         # Galibiyet yok
    "P. OETTL": 0,         # Galibiyet yok
    "A. NORRODIN": 0       # Galibiyet yok
}
# 2024 Sezonu Ortalama Yarış Sıralamaları (Gerçek Verilere Dayalı Tahmini)
Avg_RacePosition_2024 = [
    1, 2, 5, 6, 7, 8, 9, 3, 4, 12, 2, 10, 11, 9, 13, 14, 15, 16, 17, 18, 19
]  # Razgatlıoğlu 1., Bautista 2., vb.

# --- 2) Eğitim Veri Setini Oluştur ---
df_train = pd.DataFrame({
    "Rider": Riders_2024,
    "Quali24": Quali2024,
    "Avg_RaceTime_2024": Race1_2024,  # Race1_2024 verilerini ortalama zaman olarak kullan
    "Team": Teams_2024,
    "Past_Wins_Donington": [Past_Wins_Donington[rider] for rider in Riders_2024],
    "Avg_RacePosition_2024": Avg_RacePosition_2024,
    "Track": ["Donington"] * len(Riders_2024),
    "Race1_24": Race1_2024
})

# One-hot encoding
df_train = pd.get_dummies(df_train, columns=["Team", "Track"], prefix=["Team", "Track"])

# Eğitim özellikleri ve hedef
X_train = df_train[[col for col in df_train.columns if col.startswith("Quali24") or col.startswith("Avg_RaceTime") or col.startswith("Team_") or col.startswith("Past_Wins_Donington") or col.startswith("Avg_RacePosition") or col.startswith("Track_")]]
y_train = df_train["Race1_24"]

# --- 3) Veriyi Ölçeklendir ---
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# --- 4) Modeli Eğit ve Hiperparametre Optimizasyonu Yap ---
param_grid = {
    'n_estimators': [100, 200, 300],
    'learning_rate': [0.01, 0.05, 0.1],
    'max_depth': [3, 5, 8],
    'subsample': [0.7, 0.8, 0.9],
    'colsample_bytree': [0.7, 0.8, 0.9]
}
model = XGBRegressor(random_state=42)
grid_search = GridSearchCV(model, param_grid, cv=5, scoring='neg_mean_absolute_error', n_jobs=-1)
grid_search.fit(X_train_scaled, y_train)

# En iyi modeli seç
model = grid_search.best_estimator_
print(f"En iyi hiperparametreler: {grid_search.best_params_}")

# Çapraz doğrulama
cv_scores = cross_val_score(model, X_train_scaled, y_train, cv=5, scoring='neg_mean_absolute_error')
print(f"Çapraz Doğrulama MAE: {-cv_scores.mean():.3f} ± {cv_scores.std():.3f} s")

# Eğitim MAE
mae = mean_absolute_error(y_train, model.predict(X_train_scaled))
print(f"Eğitim MAE: {mae:.3f} s")

# --- 5) 2025 Superpole Verileri ---
Riders_2025 = Riders_2024.copy()
Quali2025 = [
    84.827, 84.946, 85.985, 85.347,
    85.626, 85.922, 85.532, 85.255,
    84.974, 85.764, 85.200, 85.845,
    85.574, 86.156, 86.167, 86.197,
    86.242, 86.393, 86.529, 86.607,
    86.692
]
Teams_2025 = Teams_2024.copy()
# 2025 için tahmini ortalama yarış pozisyonları (2024 verilerine dayanarak)
Avg_RacePosition_2025 = Avg_RacePosition_2024  # 2024’teki sıralamalarla başla, gerçek verilerle güncellenebilir

# Test veri setini oluştur
df_test = pd.DataFrame({
    "Rider": Riders_2025,
    "Quali25": Quali2025,
    "Avg_RaceTime_2024": Race1_2024,  # 2024 Race1 verilerini kullan
    "Team": Teams_2025,
    "Past_Wins_Donington": [Past_Wins_Donington[rider] for rider in Riders_2025],
    "Avg_RacePosition_2024": Avg_RacePosition_2025,
    "Track": ["Donington"] * len(Riders_2025)
})

# One-hot encoding
df_test = pd.get_dummies(df_test, columns=["Team", "Track"], prefix=["Team", "Track"])

# Eksik sütunları df_train'den türet ve ekle
missing_cols = [col for col in df_train.columns if col.startswith("Team_") or col.startswith("Track_") and col not in df_test.columns]
for col in missing_cols:
    df_test[col] = 0

# X_test'i oluşturmadan önce Quali25'i Quali24 olarak adlandır
df_test = df_test.rename(columns={"Quali25": "Quali24"})

# X_test'i df_train.columns ile uyumlu şekilde oluştur
X_test = df_test[[col for col in df_train.columns if col.startswith("Quali24") or col.startswith("Avg_RaceTime") or col.startswith("Team_") or col.startswith("Past_Wins_Donington") or col.startswith("Avg_RacePosition") or col.startswith("Track_")]]

# Ölçeklendirme
X_test_scaled = scaler.transform(X_test)

# --- 6) Tahmin Yap ve Sırala ---
df_test["PredictedRace1_25"] = model.predict(X_test_scaled)
df_test = df_test.sort_values("PredictedRace1_25").reset_index(drop=True)

# --- 7) Sonuçları Yazdır ---
print("\n🏍️ 2025 Race 1 Tahminleri (saniye):")
print(df_test[["Rider", "Quali24", "PredictedRace1_25"]].to_string(index=False))

# Tahmini galip
winner = df_test.loc[0, "Rider"]
print(f"\n🎉 Tahmini Galip: {winner}")

# --- 8) Görselleştirme ---
plt.figure(figsize=(12, 6))
sns.barplot(data=df_test, x="Rider", y="PredictedRace1_25", hue="Rider", palette="viridis", legend=False)
plt.xticks(rotation=45, ha='right')
plt.ylabel("Tahmini Race 1 Zamanı (s)")
plt.title("2025 WorldSBK Race 1 Tahminleri (Donington)")
plt.tight_layout()
plt.show()

# Özellik önem sıralaması
feature_importance = pd.DataFrame({
    "Feature": X_train.columns,
    "Importance": model.feature_importances_
}).sort_values("Importance", ascending=False)
plt.figure(figsize=(10, 6))
sns.barplot(data=feature_importance, x="Importance", y="Feature", hue="Feature", palette="magma", legend=False)
plt.title("Özellik Önem Sıralaması")
plt.tight_layout()
plt.show()