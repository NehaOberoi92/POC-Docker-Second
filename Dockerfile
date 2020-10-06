FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY *.sln .
COPY ["QuickStart/QuickStart.csproj", "QuickStart/"]
COPY ["QuickStart.Tests/*.csproj", "QuickStart.Tests/"]
RUN dotnet restore 
COPY . .
WORKDIR "/src/QuickStart"
RUN dotnet build "QuickStart.csproj" -c Release -o /app/build

FROM build AS test
WORKDIR "/src/QuickStart.Tests"
RUN dotnet test --logger "trx;LogFileName=QuickStart.trx" 

FROM build AS publish
RUN dotnet publish "QuickStart.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "QuickStart.dll"]
