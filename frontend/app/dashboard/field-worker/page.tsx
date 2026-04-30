export default function FieldWorkerDashboard() {
  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">Field Worker Dashboard</h1>
        <p className="text-zinc-400">Managing village clusters and farmer soil data.</p>
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-blue-500">Assigned Farmers</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-blue-500">Pending Soil Tests</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-blue-500">Villages Covered</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-blue-500">Sync Status</h3>
          <p className="text-2xl font-bold">Healthy</p>
        </div>
      </div>
    </div>
  );
}
