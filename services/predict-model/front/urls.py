from django.contrib import admin
from django.urls import path
from main_app.views import login_user, home  # Import direct des vues nécessaires

urlpatterns = [
    path('admin/', admin.site.urls),  # URL pour accéder à l'administration Django
    path('predict/', home, name='home'),  # Chemin pour la vue 'home'
    path('', login_user, name='login'),  # URL racine redirige vers la vue de login
]
