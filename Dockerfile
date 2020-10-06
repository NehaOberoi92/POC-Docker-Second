FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["QuickStart/QuickStart.csproj", "QuickStart/"]
RUN dotnet restore "QuickStart/QuickStart.csproj"
COPY . .
WORKDIR "/src/QuickStart"
RUN dotnet build "QuickStart.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "QuickStart.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "QuickStart.dll"]
