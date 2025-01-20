from django.contrib import admin
from django.urls import path
from main_app.views import login_user, home, register_user, profile  # Import direct des vues nécessaires
from django.contrib.auth import views as auth_views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('predict/', home, name='home'),
    path('', login_user, name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path("register/", register_user, name="register"),
    path("profile/", profile, name="profile"),
]
