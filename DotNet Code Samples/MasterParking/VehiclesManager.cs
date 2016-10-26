using MasterParking.Common;
using MasterParking.Core.Entities;
using MasterParking.Data;
using MasterParking.Data.Context;
using MasterParking.Repository.Models;
using MasterParking.Repository.Service;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace MasterParking.Repository.Managers
{
    public class VehiclesManager : IVehiclesRepository, IDisposable
    {

        private UnitOfWork unitOfWork = new UnitOfWork();
        private Repository<Vehicles> VehiclesRepository;
        private Repository<VehicleModel> VehicleModelRepository;
        private Repository<VehicleMake> VehicleMakeRepository;
        private Repository<VehicleColor> VehicleColorRepository;
        public VehiclesManager()
        {
            VehiclesRepository = unitOfWork.Repository<Vehicles>();
            VehicleModelRepository = unitOfWork.Repository<VehicleModel>();
            VehicleMakeRepository = unitOfWork.Repository<VehicleMake>();
            VehicleColorRepository = unitOfWork.Repository<VehicleColor>();
        }

        public bool AddVehicles(Vehicles arg)
        {
            bool result = false;
            try
            {
                Vehicles VehObj = VehiclesRepository.Table.Where(x => x.VehicleLicense == arg.VehicleLicense && x.IsActive == 1).FirstOrDefault();
                if (VehObj == null)
                {
                    VehiclesRepository.Insert(arg);
                    result = true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);
                result = false;
            }
            return result;

        }


        public List<Vehicles> GetVehicles()
        {
            List<Vehicles> vehicles = new List<Vehicles>();
            try
            {
                vehicles = VehiclesRepository.Table.Where(v => v.IsActive == 1).OrderByDescending(x => x.VehiclesID).ToList();

            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);

            }
            return vehicles;

        }
        public List<VehicleColor> GetVehicleColor()
        {
            List<VehicleColor> vehicles = new List<VehicleColor>();
            try
            {
                vehicles = VehicleColorRepository.Table.OrderBy(x => x.ColorName).ToList();

            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);

            }
            return vehicles;

        }

        public List<VehicleMake> GetVehicleMake()
        {
            List<VehicleMake> vehicles = new List<VehicleMake>();
            try
            {
                vehicles = VehicleMakeRepository.Table.OrderBy(x => x.MakeName).ToList();

            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);

            }
            return vehicles;

        }

        public List<VehicleModel> GetVehicleModel()
        {
            List<VehicleModel> vehicles = new List<VehicleModel>();
            try
            {
                vehicles = VehicleModelRepository.Table.ToList();

            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);

            }
            return vehicles;

        }

        public CustomerVehicleModel GetCustomerLicenceDetailsbyLicence(string Licence)
        {
            CustomerVehicleModel VehicleDetails = new CustomerVehicleModel();

            try
            {
                VehicleDetails = unitOfWork.SQLQuery<CustomerVehicleModel>("GetCustomerslicenceBylicenceno @licence",
                new SqlParameter("licence", SqlDbType.VarChar) { Value = Licence }).FirstOrDefault();
                return VehicleDetails;
            }
            catch (Exception ex)
            {
                return VehicleDetails;
            }
        }

        public bool DeleteVehicle(int VehicleId)
        {
            bool result = false;

            try
            {
                Vehicles vehicles = new Vehicles();
                vehicles = VehiclesRepository.GetAll().Where(x => x.VehiclesID == VehicleId).FirstOrDefault();
                if (vehicles != null)
                {
                    vehicles.IsActive = 0;
                    vehicles.EditedDate = DateTime.Now;
                    VehiclesRepository.Update(vehicles);
                    result = true;
                }                
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);
            }
            return result;
        }


        public bool UpdateCvpsVehicle(int VehicleId, long CvpsVehicleId)
        {
            bool result = false;
            Vehicles vehicles = new Vehicles();
            try
            {
                vehicles = VehiclesRepository.Table.Where(x => x.VehiclesID == VehicleId).FirstOrDefault();
                if (vehicles != null)
                {
                    vehicles.CVPSVehicleId = CvpsVehicleId;
                    VehiclesRepository.Update(vehicles);
                    return result;
                }

            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message.ToString(), this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name);

            }
            return result;

        }

        public void Dispose()
        {
            using (MPContext context = new MPContext())
            {
                context.Dispose();
            }
        }
    }
}
