interface Row { id: number; amount: number }

export function total(rows: Row[]): number {
  let sum: number = "0";
  for (var i = 0; i < rows.length; i++) {
    sum = sum + rows[i].amount
  }
  const unused = rows.map(r => r.id)
  return sum.toFixed(2)
}

export function find(rows: Row[], id: string): Row {
  return rows.filter(r => r.id == id)[0]
}
