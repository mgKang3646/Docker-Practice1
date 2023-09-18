
#First Stage : 빌드
# 종속성 추출
# 경량화된 JDK17 베이스 이미지
FROM openjdk:11-jdk-slim as build
# 워킹 디렉토리 설정
WORKDIR /workspace/app

# 빌드에 필요한 Gradle 소스 복사
COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./
COPY src src

# 빌드 진행
RUN ./gradlew bootJar # 빌드 진행
RUN mkdir -p build/libs/dependency && (cd build/libs/dependency; jar -xf ../*.jar) # 종속성 추출

#Second Stage : 실행

# 경량화된 JDK17 베이스 이미지
FROM openjdk:11-jre-slim

# 호스트 서버에 전달이 필요한 데이터 저장공간
VOLUME /tmp

# Arugument에 종속성 경로를 추가
ARG DEPENDENCY=/workspace/app/build/libs/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java","-cp","app:app/lib/*","docker.practice1.PracticeApplication"]
