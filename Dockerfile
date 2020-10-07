FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY QuickStart.sln .
COPY ["QuickStart/QuickStart.csproj", "QuickStart/"]
COPY ["QuickStart.Tests/QuickStart.Tests.csproj", "QuickStart.Tests/"]
RUN dotnet restore QuickStart.sln
COPY . .
WORKDIR "/src/QuickStart"
RUN dotnet build "QuickStart.csproj" -c Release -o /app/build

FROM build AS test
LABEL test=true
WORKDIR "/src/QuickStart.Tests"
RUN msbuild -t:restore "QuickStart.Tests.csproj"
RUN dotnet build "QuickStart.Tests.csproj"
RUN dotnet tool install dotnet-reportgenerator-globaltool --version 4.0.6 --tool-path /tools
RUN dotnet test "QuickStart.Tests.csproj" --results-directory ./testresults --logger "trx;LogFileName=test_results.xml" /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=./testresults/coverage/
RUN ls -la .
RUN ls -la

FROM build AS publish
RUN dotnet publish "QuickStart.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "QuickStart.dll"]
