from django.shortcuts import render
from django.shortcuts import render, redirect
from django.contrib.auth.forms import AuthenticationForm, UserCreationForm
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages


def home(request):
    streamlit_url = os.getenv('STREAMLIT_URL', 'http://placeholder/streamlit')
    return render(request, "index.html", {"streamlit_url": streamlit_url})


def profile(request):
    return render(request, "profile.html")


def login_user(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
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
    if request.method != 'POST':
        form = UserCreationForm()
    else:
        form = UserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'User registered successfully')
            return redirect('home')
        else:
            error_messages = " ".join([f"{field}: {', '.join(errors)}" for field, errors in form.errors.items()])
            messages.error(request, f"Une erreur est survenue : {error_messages}")

    context = {'form': form}
    return render(request, 'register.html', context)
