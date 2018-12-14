function showChangePassword() {
  document.getElementById('changePassword').style.display = "block";
  document.getElementById('passwordBtn').style.display = "none";
}

function toggleDelete() {
  var x = document.getElementById("deleteForm");
  if (x.style.display === "none") {
    x.style.display = "block";
    document.getElementById("deleteAcc").value = "NEVERMIND";
  } else {
    document.getElementById("deleteAcc").value = "DELETE ACCOUNT";
    x.style.display = "none";
  }
}
