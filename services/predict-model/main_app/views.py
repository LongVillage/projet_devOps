from django.shortcuts import render
from django.shortcuts import render, redirect
from django.contrib.auth.forms import AuthenticationForm, UserCreationForm
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages


def home(request):
    return render(request, "index.html")


# Simulated in-memory user data
mock_user = {
    'username': 'demo_user',
    'password': 'demo_password'
}


def login_user(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        # Simulate authentication with the mock user
        if username == mock_user['username'] and password == mock_user['password']:
            request.session['user'] = username  # Store user in session
            return redirect('home')
        else:
            messages.info(request, 'Username or password is incorrect')

    form = AuthenticationForm()
    return render(request, 'login.html', {'form': form})


def logout_user(request):
    request.session.flush()  # Clear the session
    return redirect('home')


def register_user(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        # For demonstration, replace the mock user data
        global mock_user
        mock_user = {
            'username': username,
            'password': password
        }
        messages.success(request, 'User registered successfully')
        return redirect('home')

    form = UserCreationForm()
    return render(request, 'register.html', {'form': form})