const admin = require("firebase-admin");
const fs = require("fs");

const serviceAccount = require("/Users/bluefog/langbat/serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function uploadData() {
  try {
    console.log("✅ Firestore 업로드 시작...");

    const data = JSON.parse(fs.readFileSync("data.json", "utf8"));

    for (const verbData of data) {
      const verbRef = db.collection("verbs").doc(verbData.text);

      console.log(`📌 업로드 중: ${verbData.text}`);

      let order = 0;

      // 🔹 시제별 동사 변형에 order 추가
      let conjugationsWithOrder = {};
      for (const [tense, forms] of Object.entries(verbData.conjugations ?? {})) {
        conjugationsWithOrder[tense] = {
          order: order, // ✅ 각 시제별 순서를 지정하여 Firestore에서 정렬 가능
          forms: forms, // 🔹 기존 형태 유지
        };
        order++; // 다음 시제의 order 값 증가
      }

      // 🔹 Firestore 문서 저장
      await verbRef.set({
        text: verbData.text,
        meaning: verbData.meaning ?? "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        frontLanguage: verbData.frontLanguage ?? "es-ES",
        backLanguage: verbData.backLanguage ?? "ko-KR",
        conjugations: conjugationsWithOrder, // ✅ order가 포함된 conjugations 저장
        examples: verbData.examples ?? {},
      });

      console.log(`✅ Firestore 업로드 완료: ${verbData.text}`);
    }

    console.log("🚀 모든 데이터 업로드 완료!");
  } catch (error) {
    console.error("❌ 업로드 중 오류 발생:", error);
  }
}

// 🔥 실행
uploadData();
