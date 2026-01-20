import{c as u}from"./VCcvzI2M.js";import{d as h,p,e as i,z as b,a as e,F as c,r as m,o as d,C as x,n,t as a,b as v,u as k}from"./4jj4Bu4Q.js";const _=u("ChevronDownIcon",[["path",{d:"m6 9 6 6 6-6",key:"qrunsl"}]]),f={class:"space-y-6"},E={class:"space-y-6"},A={class:"flex items-start justify-between mb-4"},w={class:"flex-1"},q={class:"flex items-center gap-3 mb-2"},T={class:"text-sm font-mono text-gray-900 dark:text-white"},B={class:"text-sm text-gray-600 dark:text-gray-400"},P=["onClick"],Y={key:0,class:"space-y-4 pt-4 border-t border-gray-200 dark:border-gray-700"},I={class:"p-4 bg-gray-50 dark:bg-gray-900 rounded-lg overflow-x-auto"},O={class:"text-sm"},z={class:"p-4 bg-gray-50 dark:bg-gray-900 rounded-lg overflow-x-auto"},C={class:"text-sm"},D={key:0},U={class:"overflow-x-auto"},R={class:"w-full text-sm"},S={class:"divide-y divide-gray-200 dark:divide-gray-700"},H={class:"px-4 py-2 font-mono text-gray-900 dark:text-white"},K={class:"px-4 py-2 text-gray-600 dark:text-gray-400"},L={class:"px-4 py-2"},G={class:"px-4 py-2 text-gray-600 dark:text-gray-400"},V=h({__name:"api-docs",setup(M){const o=p([]),y=p([{id:1,method:"GET",path:"/vehicles",description:"Tüm araçları listeler",requestExample:`GET /api/v1/vehicles
Headers:
  Authorization: Bearer YOUR_API_KEY
Query Parameters:
  ?page=1&limit=20&brand=BMW`,responseExample:`{
  "data": [
    {
      "id": 1,
      "brand": "BMW",
      "model": "320i",
      "year": 2020,
      "price": 850000
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}`,parameters:[{name:"page",type:"integer",required:!1,description:"Sayfa numarası"},{name:"limit",type:"integer",required:!1,description:"Sayfa başına kayıt sayısı"},{name:"brand",type:"string",required:!1,description:"Marka filtresi"}]},{id:2,method:"POST",path:"/vehicles",description:"Yeni araç oluşturur",requestExample:`POST /api/v1/vehicles
Headers:
  Authorization: Bearer YOUR_API_KEY
  Content-Type: application/json

Body:
{
  "brand": "BMW",
  "model": "320i",
  "year": 2020,
  "km": 45000,
  "price": 850000
}`,responseExample:`{
  "id": 1,
  "brand": "BMW",
  "model": "320i",
  "year": 2020,
  "km": 45000,
  "price": 850000,
  "createdAt": "2024-01-20T10:00:00Z"
}`,parameters:[{name:"brand",type:"string",required:!0,description:"Araç markası"},{name:"model",type:"string",required:!0,description:"Araç modeli"},{name:"year",type:"integer",required:!0,description:"Üretim yılı"},{name:"km",type:"integer",required:!0,description:"Kilometre"},{name:"price",type:"integer",required:!0,description:"Fiyat (TL)"}]},{id:3,method:"GET",path:"/vehicles/{id}",description:"Belirli bir aracın detaylarını getirir",requestExample:`GET /api/v1/vehicles/1
Headers:
  Authorization: Bearer YOUR_API_KEY`,responseExample:`{
  "id": 1,
  "brand": "BMW",
  "model": "320i",
  "year": 2020,
  "km": 45000,
  "price": 850000,
  "fuelType": "Benzin",
  "transmission": "Otomatik",
  "color": "Siyah"
}`,parameters:[{name:"id",type:"integer",required:!0,description:"Araç ID"}]},{id:4,method:"PUT",path:"/vehicles/{id}",description:"Araç bilgilerini günceller",requestExample:`PUT /api/v1/vehicles/1
Headers:
  Authorization: Bearer YOUR_API_KEY
  Content-Type: application/json

Body:
{
  "price": 800000
}`,responseExample:`{
  "id": 1,
  "price": 800000,
  "updatedAt": "2024-01-20T11:00:00Z"
}`,parameters:[{name:"id",type:"integer",required:!0,description:"Araç ID"},{name:"price",type:"integer",required:!1,description:"Yeni fiyat"}]},{id:5,method:"DELETE",path:"/vehicles/{id}",description:"Aracı siler",requestExample:`DELETE /api/v1/vehicles/1
Headers:
  Authorization: Bearer YOUR_API_KEY`,responseExample:`{
  "message": "Araç başarıyla silindi"
}`,parameters:[{name:"id",type:"integer",required:!0,description:"Araç ID"}]}]),g=l=>{const r=o.value.indexOf(l);r>-1?o.value.splice(r,1):o.value.push(l)};return(l,r)=>(d(),i("div",f,[r[4]||(r[4]=b('<div><h1 class="text-2xl font-bold text-gray-900 dark:text-white">API Dokümantasyonu</h1><p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Platform API&#39;sini kullanarak entegrasyonlar geliştirin</p></div><div class="bg-gradient-to-r from-primary-600 to-primary-800 rounded-2xl p-8 text-white"><h2 class="text-xl font-bold mb-4">Hızlı Başlangıç</h2><div class="space-y-4"><div><div class="text-sm text-primary-100 mb-2">Base URL</div><code class="block px-4 py-2 bg-white/20 rounded-lg font-mono text-sm">https://api.Otobia.com/v1</code></div><div><div class="text-sm text-primary-100 mb-2">Authentication</div><code class="block px-4 py-2 bg-white/20 rounded-lg font-mono text-sm">Authorization: Bearer YOUR_API_KEY</code></div></div></div>',2)),e("div",E,[(d(!0),i(c,null,m(y.value,t=>(d(),i("div",{key:t.id,class:"bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6"},[e("div",A,[e("div",w,[e("div",q,[e("span",{class:n(["px-3 py-1 text-xs font-semibold rounded-full",{"bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400":t.method==="GET","bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400":t.method==="POST","bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400":t.method==="PUT","bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400":t.method==="DELETE"}])},a(t.method),3),e("code",T,a(t.path),1)]),e("p",B,a(t.description),1)]),e("button",{onClick:s=>g(t.id),class:"p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"},[v(k(_),{class:n(["w-5 h-5 text-gray-400",{"rotate-180":o.value.includes(t.id)}])},null,8,["class"])],8,P)]),o.value.includes(t.id)?(d(),i("div",Y,[e("div",null,[r[0]||(r[0]=e("h4",{class:"font-semibold text-gray-900 dark:text-white mb-2"},"Request Example",-1)),e("pre",I,[e("code",O,a(t.requestExample),1)])]),e("div",null,[r[1]||(r[1]=e("h4",{class:"font-semibold text-gray-900 dark:text-white mb-2"},"Response Example",-1)),e("pre",z,[e("code",C,a(t.responseExample),1)])]),t.parameters&&t.parameters.length>0?(d(),i("div",D,[r[3]||(r[3]=e("h4",{class:"font-semibold text-gray-900 dark:text-white mb-2"},"Parameters",-1)),e("div",U,[e("table",R,[r[2]||(r[2]=e("thead",{class:"bg-gray-50 dark:bg-gray-700/50"},[e("tr",null,[e("th",{class:"px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400"},"Parametre"),e("th",{class:"px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400"},"Tip"),e("th",{class:"px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400"},"Gerekli"),e("th",{class:"px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400"},"Açıklama")])],-1)),e("tbody",S,[(d(!0),i(c,null,m(t.parameters,s=>(d(),i("tr",{key:s.name},[e("td",H,a(s.name),1),e("td",K,a(s.type),1),e("td",L,[e("span",{class:n(["px-2 py-1 text-xs rounded-full",s.required?"bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400":"bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400"])},a(s.required?"Evet":"Hayır"),3)]),e("td",G,a(s.description),1)]))),128))])])])])):x("",!0)])):x("",!0)]))),128))])]))}});export{V as default};
