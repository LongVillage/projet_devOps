from django.urls import path
from . import views

app_name = "main_app"  # Assurez-vous que ce nom correspond bien à l'application `main_app`.

urlpatterns = [
    path("login/", views.login_user, name="login"),
    path("logout/", views.logout_user, name="logout"),
    path("register/", views.register_user, name="register"),
]
