from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework import viewsets, permissions
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .serializers import (
    SendPasswordResetEmailSerializer, UserChangePasswordSerializer, UserLoginSerializer,
    UserPasswordResetSerializer, UserProfileSerializer, UserRegistrationSerializer,
    WorkoutSerializer, ExerciseSerializer, ProgressSerializer, GoalSerializer,
    NutritionSerializer, ActivitySerializer, FriendshipSerializer, FollowSerializer, MessageSerializer,
    ChallengeSerializer, PostSerializer, LikeSerializer, CommentSerializer, MediaSerializer
)
from .models import ( Workout, Exercise, Progress, Goal, 
                     Nutrition, Activity, Friendship, Follow, Message, Challenge, Post, Like, Comment, Media )
from .renderers import UserRenderer

# Helper function to generate JWT tokens
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Authentication Views
class UserRegistrationView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = UserRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token = get_tokens_for_user(user)
        return Response({'token': token, 'msg': 'Registration Successful'}, status=status.HTTP_201_CREATED)

class UserLoginView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = UserLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.data.get('email')
        password = serializer.data.get('password')
        user = authenticate(email=email, password=password)
        if user is not None:
            token = get_tokens_for_user(user)
            return Response({'token': token, 'msg': 'Login Success'}, status=status.HTTP_200_OK)
        else:
            return Response({'errors': {'non_field_errors': ['Email or Password is not Valid']}}, status=status.HTTP_404_NOT_FOUND)

class UserProfileView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

class UserChangePasswordView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]
    def post(self, request, format=None):
        serializer = UserChangePasswordSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password Changed Successfully'}, status=status.HTTP_200_OK)

class SendPasswordResetEmailView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = SendPasswordResetEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password Reset link sent. Please check your Email'}, status=status.HTTP_200_OK)

class UserPasswordResetView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, uid, token, format=None):
        serializer = UserPasswordResetSerializer(data=request.data, context={'uid': uid, 'token': token})
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password Reset Successfully'}, status=status.HTTP_200_OK)

# Fitness App Views
class WorkoutView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
        workouts = Workout.objects.filter(user=request.user)
        serializer = WorkoutSerializer(workouts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, format=None):
        serializer = WorkoutSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'msg': 'Workout Created Successfully'}, status=status.HTTP_201_CREATED)

class ExerciseView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, workout_id, format=None):
        exercises = Exercise.objects.filter(workout__user=request.user, workout__id=workout_id)
        serializer = ExerciseSerializer(exercises, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, workout_id, format=None):
        serializer = ExerciseSerializer(data=request.data, context={'workout_id': workout_id})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'msg': 'Exercise Added Successfully'}, status=status.HTTP_201_CREATED)

class ProgressView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
        progress = Progress.objects.filter(user=request.user)
        serializer = ProgressSerializer(progress, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, format=None):
        serializer = ProgressSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'msg': 'Progress Recorded Successfully'}, status=status.HTTP_201_CREATED)

class GoalView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
        goals = Goal.objects.filter(user=request.user)
        serializer = GoalSerializer(goals, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, format=None):
        serializer = GoalSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'msg': 'Goal Set Successfully'}, status=status.HTTP_201_CREATED)

class NutritionView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
        nutrition = Nutrition.objects.filter(user=request.user)
        serializer = NutritionSerializer(nutrition, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, format=None):
        serializer = NutritionSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'msg': 'Nutrition Recorded Successfully'}, status=status.HTTP_201_CREATED)

class ActivityView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
        activities = Activity.objects.filter(user=request.user)
        serializer = ActivitySerializer(activities, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, format=None):
        serializer = ActivitySerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'msg': 'Activity Recorded Successfully'}, status=status.HTTP_201_CREATED)
    
class FriendshipView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        friend_id = request.data.get('friend_id')
        if not friend_id:
            return Response({'error': 'Friend ID is required'}, status=status.HTTP_400_BAD_REQUEST)
        friendship = Friendship.objects.create(user=request.user, friend_id=friend_id)
        serializer = FriendshipSerializer(friendship)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class FollowView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        followed_id = request.data.get('followed_id')
        if not followed_id:
            return Response({'error': 'Followed ID is required'}, status=status.HTTP_400_BAD_REQUEST)
        follow = Follow.objects.create(follower=request.user, followed_id=followed_id)
        serializer = FollowSerializer(follow)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class MessageView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        receiver_id = request.data.get('receiver_id')
        message = request.data.get('message')
        if not receiver_id or not message:
            return Response({'error': 'Receiver ID and message are required'}, status=status.HTTP_400_BAD_REQUEST)
        message = Message.objects.create(sender=request.user, receiver_id=receiver_id, message=message)
        serializer = MessageSerializer(message)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class ChallengeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        challenges = Challenge.objects.all()
        serializer = ChallengeSerializer(challenges, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ChallengeSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
class AnalyticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        progress = Progress.objects.filter(user=user)
        workouts = Workout.objects.filter(user=user)
        goals = Goal.objects.filter(user=user)
        analytics = {
            'total_workouts': workouts.count(),
            'total_progress_entries': progress.count(),
            'goals_completed': goals.filter(status='completed').count(),
        }
        return Response(analytics)

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class LikeViewSet(viewsets.ModelViewSet):
    queryset = Like.objects.all()
    serializer_class = LikeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects.all()
    serializer_class = CommentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class MediaViewSet(viewsets.ModelViewSet):
    queryset = Media.objects.all()
    serializer_class = MediaSerializer
    