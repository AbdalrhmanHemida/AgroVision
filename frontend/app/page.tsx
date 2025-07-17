import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-green-50 to-green-200 px-4">
      <div className="max-w-2xl w-full bg-white/80 rounded-xl shadow-lg p-8 flex flex-col items-center">
        <h1 className="text-4xl md:text-5xl font-extrabold text-green-800 mb-4 text-center">
          AgroVision Pro
        </h1>
        <p className="text-lg md:text-xl text-green-900 mb-6 text-center">
          AI-Powered Agricultural Intelligence Platform
        </p>
        <p className="text-gray-700 mb-8 text-center">
          Empowering farmers, agronomists, and researchers with advanced analytics, real-time crop monitoring, and predictive insights. Harness the power of AI, data, and modern technology to revolutionize agriculture.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 w-full">
          <Feature icon="🌱" title="Crop Monitoring" desc="Real-time health and growth analytics for your fields." />
          <Feature icon="📊" title="AI Analytics" desc="Actionable insights powered by machine learning and big data." />
          <Feature icon="🌦️" title="Forecasting" desc="Weather, yield, and disease predictions to optimize planning." />
          <Feature icon="🔗" title="Seamless Integration" desc="Connect sensors, drones, and external data sources easily." />
        </div>
        <Link
          href="/dashboard"
          className="inline-block bg-green-700 hover:bg-green-800 text-white font-semibold py-3 px-8 rounded-lg shadow transition-colors text-lg"
        >
          Get Started
        </Link>
      </div>
      <footer className="mt-10 text-gray-500 text-sm text-center">
        &copy; {new Date().getFullYear()} AgroVision Pro. Empowering Smart Agriculture.
      </footer>
    </main>
  );
}

function Feature({ icon, title, desc }: { icon: string; title: string; desc: string }) {
  return (
    <div className="flex items-start space-x-3 bg-green-100 rounded-lg p-4 shadow-sm">
      <span className="text-3xl">{icon}</span>
      <div>
        <div className="font-bold text-green-800">{title}</div>
        <div className="text-green-900 text-sm">{desc}</div>
      </div>
    </div>
  );
}
