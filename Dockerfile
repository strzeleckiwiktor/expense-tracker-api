# Building stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["SampleApp.API/ExpenseTracker.API.csproj", "SampleApp.API/"]
COPY ["ExpenseTracker.Application/ExpenseTracker.Application.csproj", "ExpenseTracker.Application/"]
COPY ["ExpenseTracker.Domain/ExpenseTracker.Domain.csproj", "ExpenseTracker.Domain/"]
COPY ["ExpenseTracker.Infrastructure/ExpenseTracker.Infrastructure.csproj", "ExpenseTracker.Infrastructure/"]

RUN dotnet restore "./SampleApp.API/ExpenseTracker.API.csproj"

COPY . .
WORKDIR "/src/SampleApp.API"
ARG BUILD_CONFIGURATION=Release
RUN dotnet build "./ExpenseTracker.API.csproj" -c $BUILD_CONFIGURATION  -o /app/build

RUN dotnet publish "./ExpenseTracker.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080

ENTRYPOINT ["dotnet", "ExpenseTracker.API.dll"]
