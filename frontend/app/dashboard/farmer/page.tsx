export default function FarmerDashboard() {
  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">Farmer Dashboard</h1>
        <p className="text-zinc-400">Welcome to your personal agricultural assistant.</p>
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">My Fields</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">Recommendations</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">Active Alerts</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">Soil Health</h3>
          <p className="text-2xl font-bold">N/A</p>
        </div>
      </div>
    </div>
  );
}
